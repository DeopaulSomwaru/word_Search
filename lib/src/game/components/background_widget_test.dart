import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BackgroundWidget extends PositionComponent {
  final Color? backgroundColor;
  final String? backgroundImage;

  BackgroundWidget({this.backgroundColor, this.backgroundImage});

  @override
  Future<void> onLoad() async {
    if (backgroundImage != null) {
      final sprite = await Sprite.load(backgroundImage!);
      add(SpriteComponent(sprite: sprite, size: size));
    } else {
      add(RectangleComponent(
        size: size,
        paint: Paint()..color = backgroundColor ?? Colors.blueGrey,
      ));
    }
  }
}
