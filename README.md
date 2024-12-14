# Find The Word

A customizable word search game package for Flutter, built with Flame game engine.

## Features

- Customizable word lists
- Beautiful animations
- Game over callback for score tracking
- Responsive design
- Support for multiple word directions (horizontal, vertical, L-shape)
- Score tracking and timer
- Customizable colors and themes

## Getting started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  find_the_word: ^1.0.0
```

## Usage


```dart
import 'package:find_the_word/find_the_word.dart';

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: WordSearchGame(
          config: WordSearchConfig(
            words: ['FLUTTER', 'GAME', 'FUN', 'CODE'],
            onGameOver: (result) {
              print('Score: ${result.score}');
              print('Words Found: ${result.foundWords}');
            },
            primaryColor: Colors.purple,
            secondaryColor: Colors.pink,
            timeLimit: 180,
          ),
        ),
        overlayBuilderMap: {
          'gameOver': (context, game) => GameOverOverlay(
            game: game as WordSearchGame,
          ),
        },
      ),
    );
  }
}
```

## Additional information

- [Homepage](https://github.com/abhiiishek2000/flutter-ftw)
- [Bug Reports and Features](https://github.com/abhiiishek2000/flutter-ftw/issues)
- [Documentation](https://pub.dev/documentation/find_the_word/latest/)
