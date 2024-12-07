
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../find_the_word.dart';
import 'config/word_search_game.dart';

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