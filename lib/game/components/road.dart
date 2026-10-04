import 'dart:ui';

import 'package:flame/components.dart';

import '../emak_game.dart';

/// Jalan raya 3 jalur dengan trotoar dan cat trotoar hitam-kuning.
class Road extends Component with HasGameReference<EmakGame> {
  Road() : super(priority: -10);

  static const double _w = EmakGame.gameWidth;
  static const double _h = EmakGame.gameHeight;
  static const double _left = EmakGame.roadLeft;
  static const double _right =
      EmakGame.roadLeft + EmakGame.laneWidth * EmakGame.laneCount;

  final _sidewalk = Paint()..color = const Color(0xFFB9AE9A);
  final _sidewalkLine = Paint()
    ..color = const Color(0xFF9C917E)
    ..strokeWidth = 2;
  final _asphalt = Paint()..color = const Color(0xFF3B3B3F);
  final _curbBlack = Paint()..color = const Color(0xFF1A1A1A);
  final _curbYellow = Paint()..color = const Color(0xFFFFC400);
  final _dash = Paint()..color = const Color(0xFFEEEEEE);

  @override
  void render(Canvas canvas) {
    final scroll = game.distance;

    canvas.drawRect(const Rect.fromLTWH(0, 0, _left, _h), _sidewalk);
    canvas.drawRect(const Rect.fromLTWH(_right, 0, _w - _right, _h), _sidewalk);

    // Garis ubin trotoar.
    const tile = 40.0;
    for (var y = scroll % tile - tile; y < _h; y += tile) {
      canvas.drawLine(Offset(0, y), Offset(_left, y), _sidewalkLine);
      canvas.drawLine(Offset(_right, y), Offset(_w, y), _sidewalkLine);
    }

    canvas.drawRect(const Rect.fromLTRB(_left, 0, _right, _h), _asphalt);

    // Cat trotoar hitam-kuning.
    const stripe = 20.0;
    var i = 0;
    for (var y = scroll % (stripe * 2) - stripe * 2; y < _h; y += stripe) {
      final paint = i.isEven ? _curbBlack : _curbYellow;
      canvas.drawRect(Rect.fromLTWH(_left - 5, y, 5, stripe), paint);
      canvas.drawRect(Rect.fromLTWH(_right, y, 5, stripe), paint);
      i++;
    }

    // Marka putus-putus antar jalur.
    const dashLen = 30.0;
    for (var lane = 1; lane < EmakGame.laneCount; lane++) {
      final x = _left + EmakGame.laneWidth * lane;
      for (var y = scroll % (dashLen * 2) - dashLen * 2;
          y < _h;
          y += dashLen * 2) {
        canvas.drawRect(Rect.fromLTWH(x - 2, y, 4, dashLen), _dash);
      }
    }
  }
}
