import 'dart:ui';

import 'game_result.dart';

class WordSearchConfig {
  final List<String> words;
  final Function(GameResult) onGameOver;
  final Color primaryColor;
  final Color secondaryColor;
  final double timeLimit;
  final double wordHeight;
  final double topUIHeight;
   final double bottomUIHeight;
   final double timerWidth;
   final double scoreWidth;
   final double cellPadding;
   final double fontSize;

  WordSearchConfig({
    required this.words,
    required this.onGameOver,
    this.primaryColor = const Color(0xFF2C3E50),
    this.secondaryColor = const Color(0xFF3498DB),
    this.timeLimit = 180,
    this.wordHeight = 120,
    this.topUIHeight = 150,
    this.bottomUIHeight = 200,
    this.timerWidth = 140,
    this.scoreWidth = 20,
    this.cellPadding = 5,
    this.fontSize = 20,
  });
}
