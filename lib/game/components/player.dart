import 'dart:ui';

import 'package:flame/components.dart';

import '../emak_game.dart';

/// Motor pemain, dilihat dari belakang/atas.
class Player extends PositionComponent with HasGameReference<EmakGame> {
  Player() : super(size: Vector2(40, 66), anchor: Anchor.center, priority: 5);

  static const double _y = 540;
  static const double _steerSpeed = 900;

  int lane = 1;

  Rect get hitbox => toRect().deflate(8);

  void reset() {
    lane = 1;
    position = Vector2(EmakGame.laneX(lane), _y);
    angle = 0;
  }

  void move(int dir) {
    lane = (lane + dir).clamp(0, EmakGame.laneCount - 1);
  }

  @override
  Future<void> onLoad() async => reset();

  @override
  void update(double dt) {
    super.update(dt);
    final target = EmakGame.laneX(lane);
    final diff = target - x;
    final step = _steerSpeed * dt;
    if (diff.abs() <= step) {
      x = target;
      angle = 0;
    } else {
      x += diff.sign * step;
      angle = diff.sign * 0.22;
    }
  }

  final _tire = Paint()..color = const Color(0xFF111111);
  final _body = Paint()..color = const Color(0xFF1E88E5);
  final _jacket = Paint()..color = const Color(0xFF263238);
  final _helmet = Paint()..color = const Color(0xFFE53935);
  final _helmetStripe = Paint()..color = const Color(0xFFFFFFFF);
  final _tailLight = Paint()..color = const Color(0xFFFF1744);

  @override
  void render(Canvas canvas) {
    final w = size.x;
    // Ban depan & belakang.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w / 2 - 4, 0, 8, 14),
          const Radius.circular(3)),
      _tire,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w / 2 - 5, 52, 10, 14),
          const Radius.circular(3)),
      _tire,
    );
    // Body motor.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(8, 10, 24, 50), const Radius.circular(10)),
      _body,
    );
    // Stang.
    canvas.drawRect(const Rect.fromLTWH(2, 14, 36, 4), _tire);
    // Badan pengendara.
    canvas.drawOval(const Rect.fromLTWH(4, 26, 32, 24), _jacket);
    // Helm.
    canvas.drawCircle(Offset(w / 2, 30), 11, _helmet);
    canvas.drawRect(Rect.fromLTWH(w / 2 - 2, 19, 4, 22), _helmetStripe);
    // Lampu belakang.
    canvas.drawRect(Rect.fromLTWH(w / 2 - 6, 58, 12, 3), _tailLight);
  }
}
