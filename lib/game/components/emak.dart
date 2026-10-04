import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../emak_game.dart';
import 'obstacle.dart';
import 'pop_text.dart';

enum EmakKind {
  /// Sein kiri belok kanan (atau sebaliknya). Bintang utama game ini.
  bohong,

  /// Sein nyala tapi lurus terus.
  lurus,

  /// Tidak pakai sein, tiba-tiba belok.
  tanpaSein,

  /// Lampu hazard: belok dua kali, zig-zag.
  hazard,

  /// Langka: seinnya jujur.
  jujur,
}

/// Rencana gerak emak-emak, ditentukan saat muncul.
class EmakPlan {
  const EmakPlan({
    required this.kind,
    required this.seinKiri,
    required this.seinKanan,
    required this.moves,
  });

  final EmakKind kind;
  final bool seinKiri;
  final bool seinKanan;

  /// Arah tiap belokan: -1 kiri, 1 kanan.
  final List<int> moves;
}

EmakPlan planEmak(int lane, Random rng) {
  int validDir(int from) {
    if (from == 0) return 1;
    if (from == EmakGame.laneCount - 1) return -1;
    return rng.nextBool() ? 1 : -1;
  }

  final roll = rng.nextDouble();
  if (roll < 0.35) {
    final d = validDir(lane);
    return EmakPlan(
      kind: EmakKind.bohong,
      seinKiri: d == 1,
      seinKanan: d == -1,
      moves: [d],
    );
  } else if (roll < 0.50) {
    final kiri = rng.nextBool();
    return EmakPlan(
      kind: EmakKind.lurus,
      seinKiri: kiri,
      seinKanan: !kiri,
      moves: const [],
    );
  } else if (roll < 0.75) {
    return EmakPlan(
      kind: EmakKind.tanpaSein,
      seinKiri: false,
      seinKanan: false,
      moves: [validDir(lane)],
    );
  } else if (roll < 0.90) {
    final d1 = validDir(lane);
    final d2 = validDir(lane + d1);
    return EmakPlan(
      kind: EmakKind.hazard,
      seinKiri: true,
      seinKanan: true,
      moves: [d1, d2],
    );
  } else {
    final d = validDir(lane);
    return EmakPlan(
      kind: EmakKind.jujur,
      seinKiri: d == -1,
      seinKanan: d == 1,
      moves: [d],
    );
  }
}

class Emak extends Obstacle {
  Emak({required int lane, required Random rng})
      : _lane = lane,
        _rng = rng,
        plan = planEmak(lane, rng),
        _hijab = _hijabColors[rng.nextInt(_hijabColors.length)],
        _dress = _dressColors[rng.nextInt(_dressColors.length)],
        _scooter = _scooterColors[rng.nextInt(_scooterColors.length)],
        super(
          position: Vector2(EmakGame.laneX(lane), -60),
          size: Vector2(44, 70),
        ) {
    final first = 150 + rng.nextDouble() * 170;
    _triggers = [
      for (var i = 0; i < plan.moves.length; i++)
        first + i * (70 + rng.nextDouble() * 60),
    ];
  }

  static const _hijabColors = [
    Color(0xFFEC407A),
    Color(0xFFAB47BC),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
    Color(0xFF26C6DA),
    Color(0xFFFFEE58),
  ];
  static const _dressColors = [
    Color(0xFF6A1B9A),
    Color(0xFF00897B),
    Color(0xFFD81B60),
    Color(0xFF5D4037),
    Color(0xFF3949AB),
  ];
  static const _scooterColors = [
    Color(0xFFF48FB1),
    Color(0xFFE0E0E0),
    Color(0xFF90CAF9),
    Color(0xFFCE93D8),
  ];

  static const _swerveDuration = 0.4;

  final Random _rng;
  final EmakPlan plan;
  final Color _hijab;
  final Color _dress;
  final Color _scooter;

  int _lane;
  late final List<double> _triggers;
  int _nextMove = 0;
  double _swerveT = -1;
  double _fromX = 0;
  double _toX = 0;
  double _blink = 0;

  /// Emak lebih lambat dari pemain, jadi di layar dia "turun" pelan-pelan.
  static const double _relativeSpeed = 0.5;

  @override
  String get deathTitle => 'KENA EMAK!';

  @override
  String get deathMessage => switch (plan.kind) {
        EmakKind.bohong => plan.seinKiri
            ? 'Sein kiri, belok kanan. Emak selalu benar.'
            : 'Sein kanan, belok kiri. Namanya juga emak.',
        EmakKind.lurus => 'Seinnya cuma hiasan. Emak lurus aja.',
        EmakKind.tanpaSein => 'Emak nggak butuh sein. Emak butuh jalan.',
        EmakKind.hazard => 'Lampu hazard = bebas mau ke mana aja.',
        EmakKind.jujur => 'Emak jujur kali ini. Kamu yang nggak percaya.',
      };

  @override
  void update(double dt) {
    super.update(dt);
    _blink += dt;
    if (!isPlaying) return;

    y += game.speed * _relativeSpeed * dt;

    if (_swerveT < 0 &&
        _nextMove < plan.moves.length &&
        y >= _triggers[_nextMove]) {
      _startSwerve(plan.moves[_nextMove]);
      _nextMove++;
    }

    if (_swerveT >= 0) {
      _swerveT += dt / _swerveDuration;
      final t = min(1.0, _swerveT);
      final eased = t * t * (3 - 2 * t);
      x = _fromX + (_toX - _fromX) * eased;
      angle = (_toX - _fromX).sign * 0.3 * sin(t * pi);
      if (t >= 1) {
        _swerveT = -1;
        angle = 0;
      }
    }

    if (y > EmakGame.gameHeight + 80) removeFromParent();
  }

  void _startSwerve(int dir) {
    _lane += dir;
    _fromX = x;
    _toX = EmakGame.laneX(_lane);
    _swerveT = 0;
    final shout = plan.kind == EmakKind.jujur
        ? 'JUJUR?!'
        : const ['EH?!', 'AWAS!', 'MINGGIR!', 'BELOK!'][_rng.nextInt(4)];
    add(PopText(shout, position: Vector2(size.x / 2, -16)));
  }

  final _tire = Paint()..color = const Color(0xFF111111);
  final _lampOn = Paint()..color = const Color(0xFFFFAB00);
  final _lampOff = Paint()..color = const Color(0xFF5D4037);
  final _bag = Paint()..color = const Color(0xFF43A047);
  final _leek = Paint()
    ..color = const Color(0xFFC5E1A5)
    ..strokeWidth = 3;

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final on = (_blink % 0.5) < 0.25;

    // Ban.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w / 2 - 4, 0, 8, 14),
          const Radius.circular(3)),
      _tire,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w / 2 - 5, 56, 10, 14),
          const Radius.circular(3)),
      _tire,
    );
    // Skuter matic.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(8, 10, 28, 54), const Radius.circular(12)),
      Paint()..color = _scooter,
    );
    canvas.drawRect(const Rect.fromLTWH(2, 14, 40, 4), _tire);

    // Kantong belanjaan + daun bawang nongol.
    canvas.drawLine(const Offset(3, 30), const Offset(-2, 18), _leek);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(-4, 28, 12, 16), const Radius.circular(3)),
      _bag,
    );

    // Gamis + kerudung.
    canvas.drawOval(const Rect.fromLTWH(4, 28, 36, 28), Paint()..color = _dress);
    canvas.drawCircle(Offset(w / 2, 32), 13, Paint()..color = _hijab);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w / 2, 42), width: 30, height: 12),
      Paint()..color = _hijab,
    );

    // Lampu sein di belakang.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          const Rect.fromLTWH(3, 58, 13, 10), const Radius.circular(3)),
      plan.seinKiri && on ? _lampOn : _lampOff,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w - 16, 58, 13, 10), const Radius.circular(3)),
      plan.seinKanan && on ? _lampOn : _lampOff,
    );
    if (on) {
      final glow = Paint()
        ..color = const Color(0x99FFAB00)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      if (plan.seinKiri) canvas.drawCircle(const Offset(9, 63), 14, glow);
      if (plan.seinKanan) canvas.drawCircle(Offset(w - 9, 63), 14, glow);
    }
  }
}
