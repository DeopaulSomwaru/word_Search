import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class ScoreDisplay extends TextComponent {
  ScoreDisplay({required Vector2 position})
      : super(
          position: position,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22, // Larger font
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.blue,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
          text: 'Score: 0',
        );

  void updateScore(int score) {
    text = 'Score: $score';
    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(
          duration: 0.1,
          reverseDuration: 0.1,
        ),
      ),
    );
  }
}
