import 'dart:ui';

import 'package:flame/components.dart';

import '../emak_game.dart';

/// Semua yang bisa ditabrak pemain.
abstract class Obstacle extends PositionComponent
    with HasGameReference<EmakGame> {
  Obstacle({super.position, super.size}) : super(anchor: Anchor.center);

  /// Judul besar di layar game over.
  String get deathTitle;

  /// Kalimat lucu di bawah judul game over.
  String get deathMessage;

  double get hitboxInset => 6;

  Rect get hitbox => toRect().deflate(hitboxInset);

  bool get isPlaying => game.state == GameState.playing;
}
