import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'components/emak.dart';
import 'components/kucing.dart';
import 'components/lubang.dart';
import 'components/obstacle.dart';
import 'components/player.dart';
import 'components/pop_text.dart';
import 'components/road.dart';

enum GameState { menu, playing, crashed, over }

class EmakGame extends FlameGame with TapCallbacks, KeyboardEvents {
  // Resolusi tetap 9:16 supaya pas untuk Reels / TikTok / Stories.
  static const double gameWidth = 360;
  static const double gameHeight = 640;

  static const double roadLeft = 30;
  static const double laneWidth = 100;
  static const int laneCount = 3;

  static double laneX(int lane) => roadLeft + laneWidth * lane + laneWidth / 2;

  /// Piksel per meter untuk menghitung skor.
  static const double pixelsPerMeter = 25;

  EmakGame()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  final Random rng = Random();

  GameState state = GameState.menu;
  double speed = 0;
  double elapsed = 0;
  double distance = 0;
  double _spawnTimer = 0;
  double _crashTimer = 0;

  int best = 0;
  bool isNewRecord = false;
  String deathTitle = '';
  String deathMessage = '';

  late final Player player;
  late final TextComponent _hud;

  int get meters => distance ~/ pixelsPerMeter;

  @override
  Color backgroundColor() => const Color(0xFF000000);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(Road());
    player = Player();
    world.add(player);

    _hud = TextComponent(
      text: '',
      position: Vector2(gameWidth / 2, 20),
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: Color(0xFFFFFFFF),
          shadows: [Shadow(offset: Offset(2, 2), color: Color(0xFF000000))],
        ),
      ),
    );
    camera.viewport.add(_hud);

    overlays.add('menu');
  }

  void start() {
    world.children
        .where((c) => c is Obstacle || c is PopText)
        .toList()
        .forEach(world.remove);
    player.reset();

    state = GameState.playing;
    speed = 260;
    elapsed = 0;
    distance = 0;
    _spawnTimer = 0.8;
    _crashTimer = 0;
    isNewRecord = false;
    camera.viewfinder.position = Vector2.zero();

    overlays.remove('menu');
    overlays.remove('gameOver');
  }

  @override
  void update(double dt) {
    super.update(dt);

    switch (state) {
      case GameState.playing:
        elapsed += dt;
        speed = 260 + min(280, elapsed * 7);
        distance += speed * dt;
        _hud.text = '$meters m';

        _spawnTimer -= dt;
        if (_spawnTimer <= 0) {
          _spawn();
          final base = max(0.42, 1.15 - elapsed * 0.012);
          _spawnTimer = base * (0.8 + rng.nextDouble() * 0.4);
        }

        _checkCollisions();
      case GameState.crashed:
        _crashTimer += dt;
        // Efek layar goyang setelah tabrakan.
        final shake = max(0.0, 0.5 - _crashTimer) * 16;
        camera.viewfinder.position = Vector2(
          (rng.nextDouble() - 0.5) * shake,
          (rng.nextDouble() - 0.5) * shake,
        );
        if (_crashTimer > 0.9) {
          state = GameState.over;
          camera.viewfinder.position = Vector2.zero();
          overlays.add('gameOver');
        }
      case GameState.menu:
      case GameState.over:
        _hud.text = '';
    }
  }

  void _spawn() {
    final roll = rng.nextDouble();
    final lane = _pickFreeLane();
    if (roll < 0.68) {
      if (lane != null) world.add(Emak(lane: lane, rng: rng));
    } else if (roll < 0.88) {
      if (lane != null) world.add(Lubang(lane: lane, rng: rng));
    } else {
      world.add(Kucing(fromLeft: rng.nextBool(), rng: rng));
    }
  }

  /// Pilih jalur yang bagian atasnya masih kosong, supaya obstacle tidak
  /// muncul bertumpuk.
  int? _pickFreeLane() {
    final free = [
      for (var lane = 0; lane < laneCount; lane++)
        if (!world.children.whereType<Obstacle>().any(
              (o) => (o.x - laneX(lane)).abs() < laneWidth / 2 && o.y < 120,
            ))
          lane,
    ];
    if (free.isEmpty) return null;
    return free[rng.nextInt(free.length)];
  }

  void _checkCollisions() {
    final playerBox = player.hitbox;
    for (final o in world.children.whereType<Obstacle>()) {
      if (o.hitbox.overlaps(playerBox)) {
        _crash(o);
        return;
      }
    }
  }

  void _crash(Obstacle o) {
    state = GameState.crashed;
    speed = 0;
    deathTitle = o.deathTitle;
    deathMessage = o.deathMessage;
    if (meters > best) {
      best = meters;
      isNewRecord = true;
    }
    world.add(
      PopText(
        'BRAK!',
        position: player.position - Vector2(0, 60),
        fontSize: 44,
        color: const Color(0xFFFF3D00),
        lifetime: 2,
      ),
    );
  }

  void steer(int dir) {
    if (state == GameState.playing) player.move(dir);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Tap setengah kiri layar = ke kiri, setengah kanan = ke kanan.
    steer(event.canvasPosition.x < canvasSize.x / 2 ? -1 : 1);
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft || key == LogicalKeyboardKey.keyA) {
      steer(-1);
    } else if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.keyD) {
      steer(1);
    } else if ((key == LogicalKeyboardKey.space ||
            key == LogicalKeyboardKey.enter) &&
        (state == GameState.menu || state == GameState.over)) {
      start();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }
}
