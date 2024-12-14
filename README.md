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

<blockquote class="twitter-tweet" data-media-max-width="560"><p lang="en" dir="ltr">Hii flutter devs, i recently explored the flutter flame and created the simple find the word game with a decent animation, after all this i can say flame is very good for 2D games.<br>Also i created package for this game: <a href="https://t.co/sy9Sk0dFcc">https://t.co/sy9Sk0dFcc</a><a href="https://twitter.com/hashtag/flutter?src=hash&amp;ref_src=twsrc%5Etfw">#flutter</a> <a href="https://twitter.com/hashtag/flutterdev?src=hash&amp;ref_src=twsrc%5Etfw">#flutterdev</a> <a href="https://t.co/SEooxCmzGL">pic.twitter.com/SEooxCmzGL</a></p>&mdash; Abhishek Kumar 💙 (@tt_abhiiishek) <a href="https://twitter.com/tt_abhiiishek/status/1865374456744751358?ref_src=twsrc%5Etfw">December 7, 2024</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

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
