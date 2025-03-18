import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class WordList extends PositionComponent {
  final double fontSize;
  final List<String> words;
  final List<String> foundWords;
  final double availableWidth;
  static const double rowHeight = 20.0;
  static const double columnSpacing = 10.0;
  static const double backgroundPadding = 5.0;

  WordList({
    required this.fontSize,
    required super.position,
    required this.words,
    required this.foundWords,
    required this.availableWidth,
  });

  @override
  Future<void> onLoad() async {
    _createWordEntries();
  }

  void _createWordEntries() {
    removeAll(children);

    final columnWidth = _calculateColumnWidth();
    final wordsPerColumn = _calculateWordsPerColumn(columnWidth);
    final columnCount = (words.length / wordsPerColumn).ceil();

    for (var columnIndex = 0; columnIndex < columnCount; columnIndex++) {
      final start = columnIndex * wordsPerColumn;
      final end = (columnIndex + 1) * wordsPerColumn;
      final columnWords = words.sublist(start, end > words.length ? words.length : end);

      for (var rowIndex = 0; rowIndex < columnWords.length; rowIndex++) {
        final word = columnWords[rowIndex];
        final position = Vector2(
          columnIndex * (columnWidth + columnSpacing),
          rowIndex * rowHeight,
        );

        _createWordEntry(word, position, columnWidth);
      }
    }
  }

  double _calculateColumnWidth() => availableWidth / 2 - columnSpacing;

  int _calculateWordsPerColumn(double columnWidth) {
    final maxColumns = (availableWidth / columnWidth).floor();
    return (words.length / maxColumns).ceil();
  }

  void _createWordEntry(String word, Vector2 position, double columnWidth) {
    final isFound = foundWords.contains(word);
    
    // Background for found words
    if (isFound) {
      add(RectangleComponent(
        position: position - Vector2.all(backgroundPadding),
        size: Vector2(columnWidth, rowHeight),
        paint: Paint()
          ..color = Colors.green.withAlpha(51) // 0.2 * 255
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2),
      ));
    }

    // Text component
    add(TextComponent(
      text: word,
      position: position,
      textRenderer: TextPaint(
        style: TextStyle(
          color: isFound ? Colors.green : Colors.white70,
          fontSize: fontSize,
          fontWeight: isFound ? FontWeight.bold : FontWeight.normal,
          shadows: isFound ? _createTextShadows() : null,
        ),
      ),
    ));
  }

  List<Shadow> _createTextShadows() => const [
    Shadow(blurRadius: 4, color: Colors.green, offset: Offset.zero),
    Shadow(blurRadius: 2, color: Colors.green, offset: Offset.zero),
  ];

  @override
  void update(double dt) {
    super.update(dt);
    if (_needsRebuild) {
      _createWordEntries();
    }
  }

  bool get _needsRebuild => children.length != words.length + foundWords.length;
}