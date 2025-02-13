import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class LetterComponent extends PositionComponent {
  String letter;
  bool isSelected = false;
  bool isFound = false;
  late TextComponent textComponent;
  late RectangleComponent background;
  final Vector2 targetPosition;

  LetterComponent({
    required Vector2 position,
    required Vector2 size,
    required this.letter,
    required this.targetPosition,
  }) : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    background = RectangleComponent(
      size: size * 0.9,
      position: size * 0.05,
      paint: Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2),
    );
    add(background);

    textComponent = TextComponent(
      text: letter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              blurRadius: 8,
              color: Colors.black,
              offset: Offset(0, 0),
            ),
          ],
        ),
      ),
    );

    textComponent.position = Vector2(
      size.x / 2 - textComponent.size.x / 2,
      size.y / 2 - textComponent.size.y / 2,
    );
    add(textComponent);

    add(
      MoveEffect.to(
        targetPosition,
        EffectController(
          duration: 0.5,
          curve: Curves.elasticOut,
        ),
      ),
    );
  }

  void select() {
    isSelected = true;
    background.paint.color = Colors.amber;  // Changed to yellow/amber for drag
    add(
      ScaleEffect.by(
        Vector2.all(1.2),
        EffectController(
          duration: 0.15,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  void deselect() {
    isSelected = false;
    background.paint.color = Colors.white.withOpacity(0.1);
    add(
      ScaleEffect.by(
        Vector2.all(1/1.2),
        EffectController(
          duration: 0.15,
          curve: Curves.easeIn,
        ),
      ),
    );
  }

  void markAsFound(Color wordColor) {
    isFound = true;

    background.paint
      ..color = wordColor.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2);

    textComponent.textRenderer = TextPaint(
      style: TextStyle(
        color: wordColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            blurRadius: 4,
            color: wordColor,
            offset: const Offset(0, 0),
          ),
          Shadow(
            blurRadius: 2,
            color: wordColor,
            offset: const Offset(0, 0),
          ),
        ],
      ),
    );

    add(
      SequenceEffect([
        ScaleEffect.by(
          Vector2.all(1.3),
          EffectController(duration: 0.2),
        ),
        ScaleEffect.by(
          Vector2.all(1/1.3),
          EffectController(duration: 0.2),
        ),
      ]),
    );
  }
}
