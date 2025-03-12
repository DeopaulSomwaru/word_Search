import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class WordList extends PositionComponent {
  final List<String> words;
  final List<String> foundWords;
  final double availableWidth;
  static const double rowHeight = 20.0;

  WordList({
    required Vector2 position,
    required this.words,
    required this.foundWords,
    required this.availableWidth,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    removeAll(children);

    // Calculate how many words can fit in a column
    final double wordHeight = rowHeight;
    final double columnWidth = availableWidth / 2;

    final wordComponents = words.asMap().entries.map(
          (entry) {
        final bool isFound = foundWords.contains(entry.value);
        final wordComponent = TextComponent(
          text: entry.value,
          position: Vector2(
            (entry.key % (availableWidth ~/ columnWidth)) * columnWidth,
            (entry.key ~/ (availableWidth ~/ columnWidth)) * wordHeight,
          ),
          textRenderer: TextPaint(
            style: TextStyle(
              color: isFound ? Colors.green : Colors.white70,
              fontSize: 22,
              fontWeight: isFound ? FontWeight.bold : FontWeight.normal,
              shadows: isFound ? [
                const Shadow(
                  blurRadius: 4,
                  color: Colors.green,
                  offset: Offset(0, 0),
                ),
                const Shadow(
                  blurRadius: 2,
                  color: Colors.green,
                  offset: Offset(0, 0),
                ),
              ] : [],
            ),
          ),
        );

        // Add background for found words
        if (isFound) {
          final background = RectangleComponent(
            position: Vector2(
              (entry.key % (availableWidth ~/ columnWidth)) * columnWidth - 5,
              (entry.key ~/ (availableWidth ~/ columnWidth)) * wordHeight - 5,
            ),
            size: Vector2(columnWidth - 10, wordHeight),
            paint: Paint()
              ..color = Colors.green.withAlpha((0.2 * 255).toInt())
              ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2),
          );
          add(background);
        }

        return wordComponent;
      },
    );

    addAll(wordComponents);
  }

  @override
  void update(double dt) {
    super.update(dt);
    onLoad();
  }
}
