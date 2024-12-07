import 'package:find_the_word/src/find_the_word.dart';
import 'package:find_the_word/src/game/config/game_result.dart';
import 'package:find_the_word/src/game/config/word_search_game.dart';
import 'package:find_the_word/src/ui/menus/game_over_menu.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';


class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WordSearchGameWidget(
        config: WordSearchConfig(
          words: ['MADAN', 'KAILASH', 'ABHISHEK', 'KAMLESH'],
          onGameOver: (result) {
            // Handle game over
            print('Game Over!');
            print('Score: ${result.score}');
            print('Found Words: ${result.foundWords.length}');
            print('Win: ${result.isWin}');

            // Save to server or handle results
            saveGameResults(result);
          },
          primaryColor: Colors.purple,
          secondaryColor: Colors.pink,
          timeLimit: 180,
        ),
      ),
    );
  }

  void saveGameResults(GameResult result) {
    // Implement your server save logic here
    // Example:
    // apiService.saveGameResults(
    //   score: result.score,
    //   wordsFound: result.foundWords.length,
    //   totalWords: result.foundWords.length,
    //   isWin: result.isWin,
    //   timeRemaining: result.timeRemaining,
    // );
  }
}
class WordSearchGameWidget extends StatelessWidget {
  final WordSearchConfig config;

  const WordSearchGameWidget({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return GameWidget(
      game: WordSearchGame(config: config),
      loadingBuilder: (context) => Center(
        child: CircularProgressIndicator(
          color: config.primaryColor,
        ),

      ),
      overlayBuilderMap: {
        'gameOver': (context, game) => GameOverMenu(game: game as WordSearchGame),
      },
    );
  }
}