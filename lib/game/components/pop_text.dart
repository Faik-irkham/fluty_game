import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

/// Teks yang "meletup" lalu melayang ke atas, misalnya "EH?!" atau "BRAK!".
class PopText extends TextComponent {
  PopText(
    String text, {
    required Vector2 position,
    double fontSize = 20,
    Color color = const Color(0xFFFFEB3B),
    this.lifetime = 1,
  }) : super(
          text: text,
          position: position,
          anchor: Anchor.center,
          priority: 10,
          scale: Vector2.all(0.4),
          textRenderer: TextPaint(
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: color,
              shadows: const [
                Shadow(offset: Offset(2, 2), color: Color(0xFF000000)),
              ],
            ),
          ),
        );

  final double lifetime;
  double _age = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _age += dt;
    position.y -= 30 * dt;
    scale = Vector2.all(min(1, 0.4 + _age * 6));
    if (_age > lifetime) removeFromParent();
  }
}
