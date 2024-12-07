class GameResult {
  final int score;
  final List<String> foundWords;
  final bool isWin;
  final double timeRemaining;

  GameResult({
    required this.score,
    required this.foundWords,
    required this.isWin,
    required this.timeRemaining,
  });
}
