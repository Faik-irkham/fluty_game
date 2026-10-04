import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/emak_game.dart';
import 'game/overlays.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(EmakApp(game: EmakGame()));
}

class EmakApp extends StatelessWidget {
  const EmakApp({super.key, required this.game});

  final EmakGame game;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emak-emak Sein Kiri Belok Kanan',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: GameWidget<EmakGame>(
          game: game,
          overlayBuilderMap: {
            'menu': (context, game) => MenuOverlay(game: game),
            'gameOver': (context, game) => GameOverOverlay(game: game),
          },
        ),
      ),
    );
  }
}
