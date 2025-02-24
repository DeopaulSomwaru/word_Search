
import 'package:flutter/material.dart';
import '../../game/word_search_game.dart';

class GameOverMenu extends StatelessWidget {
  final WordSearchGame game;

  const GameOverMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withAlpha((0.3 * 255).toInt()),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              game.foundWords.length == game.words.length
                  ? 'Congratulations!'
                  : 'Game Over!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: game.foundWords.length == game.words.length
                    ? Colors.green
                    : Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Score: ${game.score}',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Words Found: ${game.foundWords.length}/${game.words.length}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
            if (game.foundWords.length == game.words.length)
              Text(
                'Time Left: ${game.timeLeft.toInt()} seconds',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
    );
  }
}