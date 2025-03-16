import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BoardComponent extends PositionComponent {
  final double bSize;
  final int gridSize;
   final double cellPadding;

  BoardComponent({required this.bSize, required this.gridSize, required this.cellPadding,});

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, bSize, bSize);
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        Colors.white,
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
      ..strokeWidth = 2.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 1);

    for (int i = 1; i < gridSize; i++) {
      canvas.drawLine(
        Offset(i * (bSize / gridSize + cellPadding), 0),
        Offset(i * (bSize / gridSize + cellPadding), bSize),
        paint,
      );
      canvas.drawLine(
      Offset(0, i * (bSize / gridSize + cellPadding)),
        Offset(bSize, i * (bSize / gridSize + cellPadding)),
        paint,
      );
    }

    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3),
    );
  }
}
