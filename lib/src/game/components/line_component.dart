import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class LineComponent extends PositionComponent {
  final Vector2 start;
  final Vector2 end;
  Paint linePaint;

  LineComponent(this.start, this.end, Color color)
      : linePaint = Paint()
    ..color = color.withAlpha((1.0 * 255).toInt())
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;

  @override
  void render(Canvas canvas) {
    canvas.drawLine(
      start.toOffset(),
      end.toOffset(),
      linePaint,
    );
  }

  void setOpacity(double opacity) {
    linePaint.color = linePaint.color.withAlpha((opacity * 255).toInt());
  }
}
