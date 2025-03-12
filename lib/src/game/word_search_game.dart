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

  WordSearchGame({required this.config}) {
    timeLeft = config.timeLimit;
    words = config.words;
  }

  late int gridSize;
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
    // Calculate the required grid size based on the longest word
    gridSize = calculateGridSize();

    // Load and add the background
    final background = BackgroundDesign();
    await add(background);
    background.size = size;

    // Set fixed heights for UI sections
    const topUIHeight = 150.0;
    const bottomUIHeight = 200.0;
    topPadding = topUIHeight;

    // Calculate cell size and grid offset
    final availableHeight = size.y - topUIHeight - bottomUIHeight;
    cellSize = min((size.x * 0.9) / gridSize, availableHeight / gridSize);
    final boardSize = cellSize * gridSize;
    gridOffset = (size.x - boardSize) / 2;

    // Initialize board and grid
    initializeBoard(boardSize);
    initializeGrid();

    // Place words and fill empty spaces
    placeWords();
    fillEmptySpaces();

    // Add letters with animation
    await addLettersWithAnimation();

    // Add UI components
    addUIComponents();
    isGameStarted = true;
    isPaused = false;
  }

  int calculateGridSize() {
    int longestWordLength = words.map((word) => word.length).reduce(max);
    return max(12, longestWordLength); // Ensure a minimum grid size of 12x12
  }

  void initializeBoard(double boardSize) {
    board = BoardComponent(
      bSize: boardSize,
      gridSize: gridSize,
    );
    board.position = Vector2(gridOffset, topPadding);
    add(board);
  }

  void initializeGrid() {
    grid = List.generate(
      gridSize,
      (i) => List.generate(
        gridSize,
        (j) => LetterComponent(
          position: Vector2(
            gridOffset + j * cellSize,
            -cellSize * (gridSize - i),
          ),
          size: Vector2.all(cellSize),
          letter: '',
          targetPosition: Vector2(
            gridOffset + j * cellSize,
            topPadding + i * cellSize,
          ),
        ),
      ),
    );
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
      position: Vector2(20, topPadding / 2),
    );
    timerDisplay = TimerDisplay(
      position: Vector2(size.x - 140, topPadding / 2),
      initialTime: timeLeft,
    );
    wordList = WordList(
      position: Vector2(20, size.y - 400 + 10),
      words: words,
      foundWords: foundWords,
      availableWidth: size.x - 20,
    );

    add(scoreDisplay);
    add(timerDisplay);
    add(wordList);
  }

  void placeWords() {
    // Sort words by length (longest first)
    words.sort((a, b) => b.length.compareTo(a.length));

    int maxAttempts = 3; // Maximum regeneration attempts
    int attempts = 0;

    while (attempts < maxAttempts) {
      // Clear the grid
      for (int i = 0; i < gridSize; i++) {
        for (int j = 0; j < gridSize; j++) {
          grid[i][j].letter = '';
        }
      }

      // Try placing words
      bool allWordsPlaced = true;
      for (String word in words) {
        bool placed = false;
        int placementAttempts = 0;

        while (!placed && placementAttempts < 500) {
          int direction = Random().nextInt(6); // Added more directions
          int row = Random().nextInt(gridSize);
          int col = Random().nextInt(gridSize);

          if (canPlaceWord(word, row, col, direction)) {
            placeWord(word, row, col, direction);
            placed = true;
          }
          placementAttempts++;
        }

        if (!placed) {
          allWordsPlaced = false;
          break;
        }
      }

      if (allWordsPlaced) {
        break; // Exit if all words are placed
      }

      attempts++;
    }

    if (attempts == maxAttempts) {
      print('Failed to place all words after $maxAttempts attempts');
    }
  }

  bool canPlaceWord(String word, int row, int col, int direction) {
    List<List<List<int>>> directions = [
      [[0, 1]],        // horizontal right
      [[1, 0]],        // vertical down
      [[0, 1], [1, 0]], // L-shape right then down
      [[1, 0], [0, 1]], // L-shape down then right
      [[1, 1]],        // diagonal down-right
      [[1, -1]],       // diagonal down-left
    ];

    if (direction >= directions.length) return false;

    List<List<int>> currentDirection = directions[direction];
    int currentRow = row;
    int currentCol = col;
    int letterIndex = 0;

    for (var segment in currentDirection) {
      int dRow = segment[0];
      int dCol = segment[1];

      int segmentLength = currentDirection.length > 1
          ? word.length ~/ 2
          : word.length;

      for (int i = 0; i < segmentLength && letterIndex < word.length; i++) {
        if (currentRow < 0 || currentRow >= gridSize ||
            currentCol < 0 || currentCol >= gridSize) {
          return false;
        }

        if (grid[currentRow][currentCol].letter.isNotEmpty &&
            grid[currentRow][currentCol].letter != word[letterIndex]) {
          return false;
        }

        currentRow += dRow;
        currentCol += dCol;
        letterIndex++;
      }
    }

    return letterIndex == word.length;
  }

  void placeWord(String word, int row, int col, int direction) {
    List<List<List<int>>> directions = [
      [[0, 1]],        // horizontal right
      [[1, 0]],        // vertical down
      [[0, 1], [1, 0]], // L-shape right then down
      [[1, 0], [0, 1]], // L-shape down then right
      [[1, 1]],        // diagonal down-right
      [[1, -1]],       // diagonal down-left
    ];

    List<List<int>> currentDirection = directions[direction];
    int currentRow = row;
    int currentCol = col;
    int letterIndex = 0;

    for (var segment in currentDirection) {
      int dRow = segment[0];
      int dCol = segment[1];

      int segmentLength = currentDirection.length > 1
          ? word.length ~/ 2
          : word.length;

      for (int i = 0; i < segmentLength && letterIndex < word.length; i++) {
        grid[currentRow][currentCol].letter = word[letterIndex];
        currentRow += dRow;
        currentCol += dCol;
        letterIndex++;
      }
    }
  }

  void fillEmptySpaces() {
    const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    Random random = Random();

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        if (grid[i][j].letter.isEmpty) {
          grid[i][j].letter = alphabet[random.nextInt(alphabet.length)];
        }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameStarted && !isPaused) {
      timeLeft -= dt;
      timerDisplay.updateTime(timeLeft.ceil());
      if (timeLeft <= 0) {
        gameOver();
      }
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

  void resetGame() {
    removeAll(children);
    score = 0;
    timeLeft = 180;
    foundWords.clear();
    wordColorMap.clear();
    isGameStarted = false;
    isPaused = false;
    onLoad();
  }

  @override
  bool onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!isGameStarted || isPaused) return false;

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

    if (cell != null) {
      List<Vector2> potentialPath = [...selectedCells, cell];
      if (isValidWordPath(potentialPath) && !selectedCells.contains(cell)) {
        selectedCells.add(cell);
        grid[cell.x.toInt()][cell.y.toInt()].select();
      }
    }
    return false;
  }

  @override
  bool onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!isGameStarted || isPaused) return false;
    checkSelectedWord();
    return false;
  }

  Vector2? getGridCell(Vector2 position) {
    double relativeX = position.x - gridOffset;
    double relativeY = position.y - topPadding;

    int col = (relativeX / cellSize).floor();
    int row = (relativeY / cellSize).floor();

    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      return Vector2(row.toDouble(), col.toDouble());
    }
    return null;
  }

  bool isValidWordPath(List<Vector2> cells) {
    if (cells.length < 2) return false;

    List<Vector2> directions = [];
    for (int i = 1; i < cells.length; i++) {
      Vector2 direction = Vector2(
        cells[i].x - cells[i - 1].x,
        cells[i].y - cells[i - 1].y,
      );
      if (!directions.contains(direction)) {
        directions.add(direction);
      }
    }

    if (directions.length > 2) return false;

    if (directions.length == 2) {
      double dot = directions[0].dot(directions[1]);
      if (dot != 0) return false;

      bool foundTurn = false;
      for (int i = 2; i < cells.length; i++) {
        Vector2 dir1 = cells[i - 1] - cells[i - 2];
        Vector2 dir2 = cells[i] - cells[i - 1];
        if (dir1 != dir2) {
          if (foundTurn) return false;
          foundTurn = true;
        }
      }
    } else {
      bool isHorizontal = cells[0].x == cells[1].x;
      for (int i = 2; i < cells.length; i++) {
        if (isHorizontal && cells[i].x != cells[0].x) return false;
        if (!isHorizontal && cells[i].y != cells[0].y) return false;
      }
    }

    return true;
  }

  void checkSelectedWord() {
    String selectedWord = getSelectedWord();

    if (words.contains(selectedWord) && !foundWords.contains(selectedWord)) {
      wordColorMap[selectedWord] = wordColors[foundWords.length % wordColors.length];
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
            gridOffset + cell.y * cellSize + cellSize / 2,
            topPadding + cell.x * cellSize + cellSize / 2,
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
          gridOffset + currentCell.y * cellSize + cellSize / 2,
          topPadding + currentCell.x * cellSize + cellSize / 2,
        ),
        Vector2(
          gridOffset + nextCell.y * cellSize + cellSize / 2,
          topPadding + nextCell.x * cellSize + cellSize / 2,
        ),
        wordColor,
      );

      add(line);

      var fadeDuration = 0.5;
      var fadeSteps = 20;
      var stepDuration = fadeDuration / fadeSteps;

      for (var i = fadeSteps - 1; i >= 0; i--) {
        Future.delayed(
          Duration(milliseconds: ((fadeSteps - i) * stepDuration * 1000).toInt()),
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
    isGameStarted = false;
    isPaused = true;

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