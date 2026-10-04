import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../emak_game.dart';
import 'obstacle.dart';

/// Lubang jalan berisi genangan air. Diam di aspal.
class Lubang extends Obstacle {
  Lubang({required int lane, required Random rng})
      : _message = _messages[rng.nextInt(_messages.length)],
        super(
          position: Vector2(EmakGame.laneX(lane), -40),
          size: Vector2(64, 40),
        );

  static const _messages = [
    'Lubang ini sudah ada sejak zaman Majapahit.',
    'Katanya diperbaiki tahun depan. Tahun depannya terus.',
    'Bukan lubang biasa. Ini kolam ikan gratis.',
  ];

  final String _message;

  @override
  String get deathTitle => 'KEJEBLOS!';

  @override
  String get deathMessage => _message;

  @override
  double get hitboxInset => 12;

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;
    y += game.speed * dt;
    if (y > EmakGame.gameHeight + 60) removeFromParent();
  }

  final _hole = Paint()..color = const Color(0xFF1C1C1E);
  final _rim = Paint()
    ..color = const Color(0xFF55555A)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  final _water = Paint()..color = const Color(0xFF5D7A8C);
  final _shine = Paint()..color = const Color(0x88FFFFFF);

  @override
  void render(Canvas canvas) {
    final r = size.toRect();
    canvas.drawOval(r, _hole);
    canvas.drawOval(r, _rim);
    canvas.drawOval(r.deflate(7), _water);
    canvas.drawOval(Rect.fromLTWH(r.width * 0.3, 12, 14, 5), _shine);
  }
}
