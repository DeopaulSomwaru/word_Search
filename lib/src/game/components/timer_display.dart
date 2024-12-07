import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TimerDisplay extends TextComponent {
  late RectangleComponent progressBar;
  final double initialTime;

  TimerDisplay({
    required Vector2 position,
    required this.initialTime,
  }) : super(
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
    text: 'Time: ${initialTime.toInt()}',
  );

  @override
  Future<void> onLoad() async {
    progressBar = RectangleComponent(
      position: Vector2(0, 32), // Positioned below text
      size: Vector2(120, 4),
      paint: Paint()
        ..color = Colors.green
        ..strokeCap = StrokeCap.round,
    );
    add(progressBar);
  }

  void updateTime(int timeLeft) {
    text = 'Time: $timeLeft';
    double progress = timeLeft / initialTime;
    progressBar.size.x = 120 * progress;

    progressBar.paint.color = ColorTween(
      begin: Colors.red,
      end: Colors.green,
    ).transform(progress) ?? Colors.green;
  }
}