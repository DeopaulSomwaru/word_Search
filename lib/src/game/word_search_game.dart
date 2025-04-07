import 'package:find_the_word/src/game/components/background_widget.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'components/board_component.dart';
import 'components/letter_component.dart';
import 'components/line_component.dart';
import 'components/score_display.dart';
import 'components/timer_display.dart';
import 'components/word_list.dart';
import 'config/game_result.dart';
import 'config/word_search_game.dart';

class WordSearchGame extends FlameGame with TapCallbacks, DragCallbacks {
  final WordSearchConfig config;

  WordSearchGame({required this.config})
      : timeLeft = config.timeLimit,
        words = config.words,
        wordHeight = config.wordHeight,
        topUIHeight = config.topUIHeight,
        bottomUIHeight = config.bottomUIHeight,
        timerWidth = config.timerWidth,
        scoreWidth = config.scoreWidth,
        cellPadding = config.cellPadding,
        fontSize = config.fontSize;

  final double gridWidthPercentage = 0.9; // Increased from 0.8
  double cellPadding = 5.0; // Space between cells

  late int gridSize;
  double fontSize = 16.0;
  late List<List<LetterComponent>> grid;
  List<String> words = [];
  List<String> foundWords = [];
  List<Vector2> selectedCells = [];
  double cellSize = 0;
  double gridOffset = 0;
  double topPadding = 0;
  int score = 0;
  double timeLeft = 180;
  bool isGameStarted = false;
  bool isPaused = false;
  double wordHeight = 20;
  double timerWidth = 20;
  double scoreWidth = 20;
  double topUIHeight = 100.0; // Reduced to give more space to the grid
  double bottomUIHeight = 150.0; // Reduced to give more space to the grid

  final List<Color> wordColors = [
    Colors.green,
    Colors.orange,
    Colors.pink,
    Colors.amber,
    Colors.red,
    Colors.purple
  ];
  final Map<String, Color> wordColorMap = {};

  late BoardComponent board;
  late ScoreDisplay scoreDisplay;
  late TimerDisplay timerDisplay;
  late WordList wordList;
  late BackgroundDesign backgroundComponent;

  @override
  Future<void> onLoad() async {
    // 1. Calculate grid size FIRST
    gridSize = calculateGridSize();

    // 2. Calculate cell padding SECOND (depends on gridSize)
    // cellPadding = _calculateCellPaddingFor();

    // 3. Calculate available space THIRD
    final availableWidth = size.x * gridWidthPercentage - (gridSize * 2);
    final availableHeight =
        size.y - topUIHeight - bottomUIHeight - (gridSize * 2);

    // 4. Calculate cell size FOURTH (depends on gridSize and cellPadding)
    cellSize = min(
      (availableWidth - (cellPadding * (gridSize - 1))) / gridSize,
      (availableHeight - (cellPadding * (gridSize - 1))) / gridSize,
    ).clamp(25.0, 40.0);

    // 5. Initialize visual components
    final background = BackgroundDesign();
    await add(background);
    background.size = size;

    // 6. Calculate board dimensions
    final boardWidth = (cellSize * gridSize) + (cellPadding * (gridSize - 1));
    final boardHeight = (cellSize * gridSize) + (cellPadding * (gridSize - 1));
    gridOffset = (size.x - boardWidth) / 2;
    topPadding = topUIHeight;

    // 7. Initialize game components
    initializeBoard(boardWidth, boardHeight);
    initializeGrid();
    placeWords();
    fillEmptySpaces();
    await addLettersWithAnimation();
    addUIComponents();

    // 8. Start game
    isGameStarted = true;
  }
  // Future<void> onLoad() async {
  //   // New cell size calculation with padding consideration
  //   final availableWidth = size.x * gridWidthPercentage - (gridSize * 2);
  //   final availableHeight =
  //       size.y - topUIHeight - bottomUIHeight - (gridSize * 2);

  //   cellSize = min(
  //     (availableWidth - (cellPadding * (gridSize - 1))) / gridSize,
  //     (availableHeight - (cellPadding * (gridSize - 1))) / gridSize,
  //   ).clamp(25.0, 40.0); // Clamp to reasonable size
  //   gridSize = calculateGridSize();
  //   cellPadding = _calculateCellPadding(); // New dynamic padding calculation

  //   final background = BackgroundDesign();
  //   await add(background);
  //   background.size = size;

  //   topPadding = topUIHeight;

  //   // Calculate cell size with padding
  //   // final availableWidth = size.x * gridWidthPercentage;
  //   // final availableHeight = size.y - topUIHeight - bottomUIHeight;
  //   cellSize = min(
  //     (availableWidth - (cellPadding * (gridSize - 1))) / gridSize,
  //     (availableHeight - (cellPadding * (gridSize - 1))) / gridSize,
  //   );

  //   // Calculate total board size including padding
  //   final boardWidth = (cellSize * gridSize) + (cellPadding * (gridSize - 1));
  //   final boardHeight = (cellSize * gridSize) + (cellPadding * (gridSize - 1));

  //   gridOffset = (size.x - boardWidth) / 2;

  //   initializeBoard(boardWidth, boardHeight);
  //   initializeGrid();
  //   placeWords();
  //   fillEmptySpaces();
  //   await addLettersWithAnimation();
  //   addUIComponents();
  //   isGameStarted = true;
  // }

  // int calculateGridSize() {
  //   int longestWordLength = words.map((word) => word.length).reduce(max);
  //   return max(10, longestWordLength); // Ensure a minimum grid size of 10x10
  // }
  // int calculateGridSize() {
  //   final longestWordLength = words.map((word) => word.length).reduce(max);
  //   final wordCount = words.length;

  //   // Calculate buffer based on the square root of word count to handle density
  //   final buffer = sqrt(wordCount).ceil();

  //   // Base size on longest word plus buffer, ensuring minimum size for placement
  //   int calculatedSize = longestWordLength + buffer;

  //   // Clamp between minimum and maximum to prevent overly large grids
  //   return calculatedSize.clamp(longestWordLength + 2, 20);
  // }

  int calculateGridSize() {
    final longestWord = words.map((word) => word.length).reduce(max);
    final wordCount = words.length;

    // New grid size formula
    int baseSize = longestWord + (wordCount ~/ 2);
    int buffer = (baseSize * 0.3).ceil();

    int sizeWithBuffer = baseSize + buffer;

    // Try max size that fits the screen (fallback clamp)
    for (int s = sizeWithBuffer.clamp(10, 25); s >= longestWord + 2; s--) {
      double testCellSize = min(
        (size.x * gridWidthPercentage - (s - 1) * _calculateCellPaddingFor(s)) /
            s,
        ((size.y - topUIHeight - bottomUIHeight) -
                (s - 1) * _calculateCellPaddingFor(s)) /
            s,
      );
      if (testCellSize >= 25.0) return s;
    }

    return longestWord + 2;
  }

  double _calculateCellPaddingFor(int size) {
    final basePadding = 8.0 + (size * 0.2);
    return basePadding.clamp(10.0, 15.0);
  }

  void initializeBoard(double boardWidth, double boardHeight) {
    board = BoardComponent(
      bSize: boardWidth,
      gridSize: gridSize,
      cellPadding: cellPadding,
    );
    board.position = Vector2(gridOffset, topPadding);
    add(board);
  }

  void initializeGrid() {
    grid = List.generate(
        gridSize,
        (i) => List.generate(gridSize, (j) {
              final paddingOffset = cellPadding * j;
              return LetterComponent(
                  position: Vector2(
                    gridOffset + j * (cellSize + cellPadding) + paddingOffset,
                    topPadding + i * (cellSize + cellPadding) + paddingOffset,
                  ),
                  size: Vector2.all(cellSize),
                  letter: '',
                  targetPosition: Vector2(
                    gridOffset + j * (cellSize + cellPadding),
                    topPadding + i * (cellSize + cellPadding),
                  ));
            }));
  }

  Future<void> addLettersWithAnimation() async {
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        add(grid[i][j]);
        await Future.delayed(const Duration(milliseconds: 10));
      }
    }
  }

  void addUIComponents() {
    scoreDisplay = ScoreDisplay(
      position: Vector2(scoreWidth, topPadding / 2),
    );
    timerDisplay = TimerDisplay(
      position: Vector2(size.x - timerWidth, topPadding / 2),
      initialTime: timeLeft,
    );
    wordList = WordList(
      fontSize: fontSize,
      position: Vector2(20, size.y - wordHeight + 10),
      words: words,
      foundWords: foundWords,
      availableWidth: size.x - 20,
    );

    add(scoreDisplay);
    add(timerDisplay);
    add(wordList);
  }

  void placeWords() {
    words.sort((a, b) => b.length.compareTo(a.length));
    Random random = Random();
    List<List<int>> directions = [
      [0, 1], // Right
      [1, 0], // Down
      [0, -1], // Left
      [-1, 0], // Up
    ];

    for (String word in words) {
      bool placed = false;
      int attempts = 0;

      while (!placed && attempts < 1000) {
        int dirIndex = random.nextInt(directions.length);
        int row = random.nextInt(gridSize);
        int col = random.nextInt(gridSize);

        if (canPlaceWord(word, row, col, dirIndex)) {
          placeWord(word, row, col, dirIndex);
          placed = true;
        }
        attempts++;
      }

      if (!placed) {
        debugPrint('Failed to place word: $word');
      }
    }
  }

  // bool canPlaceWord(String word, int row, int col, int direction) {
  //   List<List<List<int>>> directions = [
  //     [
  //       [0, 1]
  //     ], // horizontal right
  //     [
  //       [1, 0]
  //     ], // vertical down
  //     [
  //       [0, 1],
  //       [1, 0]
  //     ], // L-shape right then down
  //     [
  //       [1, 0],
  //       [0, 1]
  //     ], // L-shape down then right
  //     [
  //       [1, 1]
  //     ], // diagonal down-right
  //     [
  //       [1, -1]
  //     ], // diagonal down-left
  //   ];

  //   if (direction >= directions.length) return false;

  //   List<List<int>> currentDirection = directions[direction];
  //   int currentRow = row;
  //   int currentCol = col;
  //   int letterIndex = 0;

  //   for (var segment in currentDirection) {
  //     int dRow = segment[0];
  //     int dCol = segment[1];

  //     int segmentLength =
  //         currentDirection.length > 1 ? word.length ~/ 2 : word.length;

  //     for (int i = 0; i < segmentLength && letterIndex < word.length; i++) {
  //       if (currentRow < 0 ||
  //           currentRow >= gridSize ||
  //           currentCol < 0 ||
  //           currentCol >= gridSize) {
  //         return false;
  //       }

  //       if (grid[currentRow][currentCol].letter.isNotEmpty &&
  //           grid[currentRow][currentCol].letter != word[letterIndex]) {
  //         return false;
  //       }

  //       currentRow += dRow;
  //       currentCol += dCol;
  //       letterIndex++;
  //     }
  //   }

  //   return letterIndex == word.length;
  // }

  bool canPlaceWord(String word, int row, int col, int direction) {
    List<List<int>> dirs = [
      [0, 1],
      [1, 0],
      [0, -1],
      [-1, 0]
    ];
    if (direction >= dirs.length) return false;

    int dRow = dirs[direction][0];
    int dCol = dirs[direction][1];

    // Calculate required space
    int endRow = row + dRow * (word.length - 1);
    int endCol = col + dCol * (word.length - 1);

    // Check if the word fits within grid boundaries
    if (endRow < 0 || endRow >= gridSize || endCol < 0 || endCol >= gridSize) {
      return false;
    }

    // Check each cell in the path
    for (int i = 0; i < word.length; i++) {
      int r = row + dRow * i;
      int c = col + dCol * i;

      String cellLetter = grid[r][c].letter;
      if (cellLetter.isNotEmpty && cellLetter != word[i]) {
        return false;
      }
    }

    return true;
  }

  void placeWord(String word, int row, int col, int direction) {
    final directions = [
      [0, 1], // Right
      [1, 0], // Down
      [0, -1], // Left
      [-1, 0] // Up
    ];

    if (direction >= directions.length) return;

    int dRow = directions[direction][0];
    int dCol = directions[direction][1];

    for (int i = 0; i < word.length; i++) {
      int currentRow = row + dRow * i;
      int currentCol = col + dCol * i;

      if (currentRow >= 0 &&
          currentRow < gridSize &&
          currentCol >= 0 &&
          currentCol < gridSize) {
        grid[currentRow][currentCol].letter = word[i];
      }
    }
  }

  // void fillEmptySpaces() {
  //   const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  //   Random random = Random();

  //   for (int i = 0; i < gridSize; i++) {
  //     for (int j = 0; j < gridSize; j++) {
  //       if (grid[i][j].letter.isEmpty) {
  //         grid[i][j].letter = alphabet[random.nextInt(alphabet.length)];
  //       }
  //     }
  //   }
  // }

  void fillEmptySpaces() {
    const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    Random random = Random();
    double fillProbability =
        0.6; // 60% chance to fill a cell (adjust as needed)

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].letter.isEmpty) {
          // Only fill cells randomly based on probability
          if (random.nextDouble() < fillProbability) {
            grid[i][j].letter = alphabet[random.nextInt(alphabet.length)];
          }
        }
      }
    }
  }

  // @override
  // void update(double dt) {
  //   super.update(dt);
  //   if (isGameStarted && !isPaused) {
  //     timeLeft -= dt;
  //     timerDisplay.updateTime(timeLeft.ceil());
  //     if (timeLeft <= 0) {
  //       gameOver();
  //     }
  //   }
  // }

  bool _gameOverCalled = false;

  @override
  void update(double dt) {
    if (!isGameStarted || isPaused || _gameOverCalled) return;

    super.update(dt);
    timeLeft -= dt;
    timerDisplay.updateTime(timeLeft.ceil());

    if (timeLeft <= 0) {
      _gameOverCalled = true;
      gameOver();
    }
  }

  void startGame() {
    isGameStarted = true;
    isPaused = false;
  }

  void pauseGame() {
    isPaused = true;
    overlays.add('pause');
  }

  void resumeGame() {
    isPaused = false;
    overlays.remove('pause');
  }

  void resetGame() async {
    removeAll(children);
    score = 0;
    timeLeft = 180;
    foundWords.clear();
    wordColorMap.clear();
    isGameStarted = false;
    isPaused = false;
    await onLoad();
  }

  @override
  bool onDragStart(DragStartEvent event) {
    if (!isGameStarted || isPaused) return false;
    super.onDragStart(event);

    Vector2? cell = getGridCell(event.canvasPosition);

    if (cell != null) {
      selectedCells = [cell];
      grid[cell.x.toInt()][cell.y.toInt()].select();
    }
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateEvent event) {
    if (!isGameStarted || isPaused) return false;

    Vector2? cell = getGridCell(event.canvasStartPosition);
    if (cell == null || selectedCells.contains(cell)) return false;

    List<Vector2> potentialPath = [...selectedCells, cell];
    if (!isValidWordPath(potentialPath)) return false;

    selectedCells.add(cell);
    grid[cell.x.toInt()][cell.y.toInt()].select();
    return true;
  }

  // @override
  // bool onDragUpdate(DragUpdateEvent event) {
  //   if (!isGameStarted || isPaused) return false;

  //   Vector2? cell = getGridCell(event.canvasStartPosition);

  //   if (cell != null) {
  //     List<Vector2> potentialPath = [...selectedCells, cell];
  //     if (isValidWordPath(potentialPath) && !selectedCells.contains(cell)) {
  //       selectedCells.add(cell);
  //       grid[cell.x.toInt()][cell.y.toInt()].select();
  //     }
  //   }
  //   return false;
  // }

  @override
  bool onDragEnd(DragEndEvent event) {
    if (!isGameStarted || isPaused) return false;
    super.onDragEnd(event);
    checkSelectedWord();
    return false;
  }

  Vector2? getGridCell(Vector2 position) {
    double relativeX = position.x - gridOffset;
    double relativeY = position.y - topPadding;

    int col = (relativeX / (cellSize + cellPadding)).floor();
    int row = (relativeY / (cellSize + cellPadding)).floor();

    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      return Vector2(row.toDouble(), col.toDouble());
    }
    return null;
  }

  // bool isValidWordPath(List<Vector2> cells) {
  //   if (cells.length < 2) return false;

  //   List<Vector2> directions = [];
  //   for (int i = 1; i < cells.length; i++) {
  //     Vector2 direction = Vector2(
  //       cells[i].x - cells[i - 1].x,
  //       cells[i].y - cells[i - 1].y,
  //     );
  //     if (!directions.contains(direction)) {
  //       directions.add(direction);
  //     }
  //   }

  //   if (directions.length > 2) return false;

  //   if (directions.length == 2) {
  //     double dot = directions[0].dot(directions[1]);
  //     if (dot != 0) return false;

  //     bool foundTurn = false;
  //     for (int i = 2; i < cells.length; i++) {
  //       Vector2 dir1 = cells[i - 1] - cells[i - 2];
  //       Vector2 dir2 = cells[i] - cells[i - 1];
  //       if (dir1 != dir2) {
  //         if (foundTurn) return false;
  //         foundTurn = true;
  //       }
  //     }
  //   } else {
  //     bool isHorizontal = cells[0].x == cells[1].x;
  //     for (int i = 2; i < cells.length; i++) {
  //       if (isHorizontal && cells[i].x != cells[0].x) return false;
  //       if (!isHorizontal && cells[i].y != cells[0].y) return false;
  //     }
  //   }

  //   return true;
  // }
  bool isValidWordPath(List<Vector2> cells) {
    if (cells.length < 2) return false;

    // Check if all moves are in the same direction (straight line)
    Vector2 initialDir = (cells[1] - cells[0]).normalized();
    bool isStraight = true;

    for (int i = 2; i < cells.length; i++) {
      Vector2 dir = (cells[i] - cells[i - 1]).normalized();
      if (dir != initialDir) {
        isStraight = false;
        break;
      }
    }

    if (isStraight) return true;

    // Check for exactly one right-angle turn
    int turnCount = 0;
    Vector2 prevDir = (cells[1] - cells[0]).normalized();

    for (int i = 2; i < cells.length; i++) {
      Vector2 currDir = (cells[i] - cells[i - 1]).normalized();
      if (currDir != prevDir) {
        if (prevDir.dot(currDir) != 0) return false; // Not a right angle
        if (++turnCount > 1) return false; // More than one turn
        prevDir = currDir;
      }
    }

    return turnCount == 1;
  }

  void checkSelectedWord() {
    String selectedWord = getSelectedWord();

    if (words.contains(selectedWord) && !foundWords.contains(selectedWord)) {
      wordColorMap[selectedWord] =
          wordColors[foundWords.length % wordColors.length];
      foundWords.add(selectedWord);
      updateScore(selectedWord.length * 10);
      addWordFoundEffect(wordColorMap[selectedWord]!);

      if (foundWords.length == words.length) {
        gameOver(true);
      }
    }

    resetSelection();
  }

  String getSelectedWord() {
    return selectedCells
        .map((cell) => grid[cell.x.toInt()][cell.y.toInt()].letter)
        .join();
  }

  void updateScore(int points) {
    score += points;
    scoreDisplay.updateScore(score);
  }

  void resetSelection() {
    for (var cell in selectedCells) {
      grid[cell.x.toInt()][cell.y.toInt()].deselect();
    }
    selectedCells.clear();
  }

  void addWordFoundEffect(Color wordColor) {
    for (var cell in selectedCells) {
      add(
        ParticleSystemComponent(
          position: Vector2(
            gridOffset + cell.y * (cellSize + cellPadding) + cellSize / 2,
            topPadding + cell.x * (cellSize + cellPadding) + cellSize / 2,
          ),
          particle: Particle.generate(
            count: 20,
            lifespan: 1,
            generator: (i) => AcceleratedParticle(
              speed: Vector2(
                Random().nextDouble() * 100 - 50,
                Random().nextDouble() * 100 - 50,
              ),
              acceleration: Vector2(0, 98),
              child: CircleParticle(
                radius: 2,
                paint: Paint()..color = wordColor,
              ),
            ),
          ),
        ),
      );

      grid[cell.x.toInt()][cell.y.toInt()].markAsFound(wordColor);
    }

    for (int i = 0; i < selectedCells.length - 1; i++) {
      var currentCell = selectedCells[i];
      var nextCell = selectedCells[i + 1];

      var line = LineComponent(
        Vector2(
          gridOffset + currentCell.y * (cellSize + cellPadding) + cellSize / 2,
          topPadding + currentCell.x * (cellSize + cellPadding) + cellSize / 2,
        ),
        Vector2(
          gridOffset + nextCell.y * (cellSize + cellPadding) + cellSize / 2,
          topPadding + nextCell.x * (cellSize + cellPadding) + cellSize / 2,
        ),
        wordColor,
      );

      add(line);

      var fadeDuration = 0.5;
      var fadeSteps = 20;
      var stepDuration = fadeDuration / fadeSteps;

      for (var i = fadeSteps - 1; i >= 0; i--) {
        Future.delayed(
          Duration(
              milliseconds: ((fadeSteps - i) * stepDuration * 1000).toInt()),
          () {
            line.setOpacity(i / fadeSteps);
            if (i == 0) {
              line.removeFromParent();
            }
          },
        );
      }
    }
  }

  void gameOver([bool victory = false]) {
    if (_gameOverCalled) return;
    _gameOverCalled = true;
    isGameStarted = false;

    config.onGameOver(
      GameResult(
        score: score,
        foundWords: foundWords,
        isWin: victory || foundWords.length == words.length,
        timeRemaining: timeLeft,
      ),
    );

    overlays.remove('pause');
    overlays.add('gameOver');
  }
}
