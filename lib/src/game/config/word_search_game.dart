import 'dart:ui';

import 'game_result.dart';

class WordSearchConfig {
  final List<String> words;
  final Function(GameResult) onGameOver;
  final Color primaryColor;
  final Color secondaryColor;
  final double timeLimit;
  final double wordHeight;

  WordSearchConfig({
    required this.words,
    required this.onGameOver,
    this.primaryColor = const Color(0xFF2C3E50),
    this.secondaryColor = const Color(0xFF3498DB),
    this.timeLimit = 180,
    this.wordHeight = 120
  });
}
