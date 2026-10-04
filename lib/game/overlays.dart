import 'package:flutter/material.dart';

import 'emak_game.dart';

const _yellow = Color(0xFFFFC400);
const _orange = Color(0xFFFF6D00);

TextStyle _chunky(double size, {Color color = Colors.white}) => TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      color: color,
      height: 1.05,
      shadows: const [Shadow(offset: Offset(3, 3), color: Colors.black)],
    );

class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class _GasButton extends StatelessWidget {
  const _GasButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: _orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label, style: _chunky(26)),
    );
  }
}

class MenuOverlay extends StatelessWidget {
  const MenuOverlay({super.key, required this.game});

  final EmakGame game;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      children: [
        Text('EMAK-EMAK', style: _chunky(48, color: _yellow)),
        const SizedBox(height: 4),
        Text(
          'SEIN KIRI\nBELOK KANAN',
          textAlign: TextAlign.center,
          style: _chunky(34),
        ),
        const SizedBox(height: 28),
        Text(
          'Tap kiri / kanan layar\nuntuk pindah jalur.\n\nJangan percaya sein.',
          textAlign: TextAlign.center,
          style: _chunky(18),
        ),
        const SizedBox(height: 36),
        _GasButton(label: 'GAS!', onPressed: game.start),
      ],
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  final EmakGame game;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      children: [
        Text(
          game.deathTitle,
          textAlign: TextAlign.center,
          style: _chunky(46, color: _yellow),
        ),
        const SizedBox(height: 12),
        Text(
          game.deathMessage,
          textAlign: TextAlign.center,
          style: _chunky(20),
        ),
        const SizedBox(height: 32),
        Text('${game.meters} m', style: _chunky(64)),
        if (game.isNewRecord)
          Text('REKOR BARU!', style: _chunky(24, color: _orange))
        else
          Text('Rekor: ${game.best} m', style: _chunky(20)),
        const SizedBox(height: 32),
        _GasButton(label: 'MAIN LAGI', onPressed: game.start),
        const SizedBox(height: 20),
        Text(
          'Tag temanmu, bisa lewat nggak?',
          style: _chunky(16, color: Colors.white70),
        ),
      ],
    );
  }
}
