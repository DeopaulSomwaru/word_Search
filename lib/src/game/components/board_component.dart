import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BoardComponent extends PositionComponent {
  final double bSize;
  final int gridSize;

  BoardComponent({required this.bSize, required this.gridSize});

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, bSize, bSize);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF2C3E50),
        const Color(0xFF3498DB),
      ],
    ).createShader(rect);

    canvas.drawRect(
        rect,
        Paint()
          ..shader = gradient
          ..style = PaintingStyle.fill
    );

    final cellSize = bSize / gridSize;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 1);

    for (int i = 1; i < gridSize; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, bSize),
        paint,
      );
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(bSize, i * cellSize),
        paint,
      );
    }

    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3),
    );
  }
}
