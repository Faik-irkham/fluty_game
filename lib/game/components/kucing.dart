import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../emak_game.dart';
import 'obstacle.dart';
import 'pop_text.dart';

/// Kucing oren yang nyebrang tanpa lihat kiri-kanan.
class Kucing extends Obstacle {
  Kucing({required this.fromLeft, required Random rng})
      : _walkFactor = 0.3 + rng.nextDouble() * 0.2,
        super(
          position: Vector2(fromLeft ? -20 : EmakGame.gameWidth + 20, -30),
          size: Vector2(38, 22),
        );

  final bool fromLeft;
  final double _walkFactor;
  bool _meowed = false;

  @override
  String get deathTitle => 'MEONG!';

  @override
  String get deathMessage => 'Kucingnya selamat. Kamu yang nggak.';

  @override
  double get hitboxInset => 4;

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;
    y += game.speed * dt;
    x += (fromLeft ? 1 : -1) * game.speed * _walkFactor * dt;

    if (!_meowed && y > 60) {
      _meowed = true;
      add(PopText('MEONG', position: Vector2(size.x / 2, -12), fontSize: 16));
    }

    if (y > EmakGame.gameHeight + 40 ||
        x < -60 ||
        x > EmakGame.gameWidth + 60) {
      removeFromParent();
    }
  }

  final _fur = Paint()..color = const Color(0xFFFF9800);
  final _stripe = Paint()
    ..color = const Color(0xFFE65100)
    ..strokeWidth = 2.5;
  final _tail = Paint()
    ..color = const Color(0xFFFF9800)
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.stroke;

  @override
  void render(Canvas canvas) {
    canvas.save();
    if (!fromLeft) {
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    }
    // Ekor.
    final tail = Path()
      ..moveTo(4, 11)
      ..quadraticBezierTo(-6, 4, -2, -4);
    canvas.drawPath(tail, _tail);
    // Badan.
    canvas.drawOval(const Rect.fromLTWH(2, 3, 26, 16), _fur);
    for (final sx in [10.0, 15.0, 20.0]) {
      canvas.drawLine(Offset(sx, 5), Offset(sx, 17), _stripe);
    }
    // Kepala + telinga.
    canvas.drawCircle(const Offset(30, 11), 8, _fur);
    canvas.drawPath(
      Path()
        ..moveTo(27, 5)
        ..lineTo(29, -2)
        ..lineTo(33, 4)
        ..close(),
      _fur,
    );
    canvas.drawPath(
      Path()
        ..moveTo(27, 17)
        ..lineTo(29, 24)
        ..lineTo(33, 18)
        ..close(),
      _fur,
    );
    canvas.restore();
  }
}
