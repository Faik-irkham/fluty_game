import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:fluty_game/game/components/emak.dart';
import 'package:fluty_game/game/emak_game.dart';

void main() {
  test('emak-emak tidak pernah belok keluar jalan', () {
    for (var seed = 0; seed < 2000; seed++) {
      final rng = Random(seed);
      for (var lane = 0; lane < EmakGame.laneCount; lane++) {
        final plan = planEmak(lane, rng);
        var current = lane;
        for (final move in plan.moves) {
          current += move;
          expect(current, inInclusiveRange(0, EmakGame.laneCount - 1));
        }
      }
    }
  });

  test('sein emak bohong selalu berlawanan dengan arah belok', () {
    final rng = Random(1);
    var checked = 0;
    while (checked < 200) {
      final plan = planEmak(rng.nextInt(EmakGame.laneCount), rng);
      if (plan.kind != EmakKind.bohong) continue;
      final belokKanan = plan.moves.single == 1;
      expect(plan.seinKiri, belokKanan);
      expect(plan.seinKanan, !belokKanan);
      checked++;
    }
  });
}
