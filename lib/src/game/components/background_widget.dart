import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class BackgroundDesign extends PositionComponent with HasGameRef {
  late ui.Image backgroundImage;
  late ui.Image topBackgroundImage;
  late ui.Image topDecorationImage;
  late ui.Image bottomDecorationImage;

  @override
  Future<void> onLoad() async {
    size = gameRef.size; // Set component to full screen

    backgroundImage = await Flame.images.load('background.webp');
    topBackgroundImage = await Flame.images.load('background.webp');
    topDecorationImage = await Flame.images.load('topframe.png');
    bottomDecorationImage = await Flame.images.load('bottomframe.png');
  }

 @override
void render(Canvas canvas) {
  final size = this.size;

  // Fill the background with the desired color
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.x, size.y),
    Paint()..color = const Color.fromRGBO(232, 219, 177, 1),
  );

  final rect = Rect.fromLTWH(0, 0, size.x, size.y);

  // Draw the bottom background image (scaled to fill the screen)
  canvas.drawImageRect(
    backgroundImage,
    Rect.fromLTWH(0, 0, backgroundImage.width.toDouble(), backgroundImage.height.toDouble()),
    rect,
    Paint(),
  );

  // Draw the top background image (scaled & rotated upside down)
  canvas.save();
  canvas.translate(size.x, 0); // Move to the right before rotation
  canvas.rotate(3.14159); // Rotate 180 degrees (Pi radians)
  canvas.drawImageRect(
    topBackgroundImage,
    Rect.fromLTWH(0, 0, topBackgroundImage.width.toDouble(), topBackgroundImage.height.toDouble()),
    rect,
    Paint(),
  );
  canvas.restore();

  // **Draw the top vines decoration (added back!)**
  final vinesRect = Rect.fromLTWH(0, -10, size.x, 200); // Adjust for vines
  canvas.drawImageRect(
    topDecorationImage,
    Rect.fromLTWH(0, 0, topDecorationImage.width.toDouble(), topDecorationImage.height.toDouble()),
    vinesRect,
    Paint(),
  );

  // **Draw the bottom decoration**
  final bottomDecorationRect = Rect.fromLTWH(0, size.y - 120, size.x, 200);
  canvas.drawImageRect(
    bottomDecorationImage,
    Rect.fromLTWH(0, 0, bottomDecorationImage.width.toDouble(), bottomDecorationImage.height.toDouble()),
    bottomDecorationRect,
    Paint(),
  );
}
}