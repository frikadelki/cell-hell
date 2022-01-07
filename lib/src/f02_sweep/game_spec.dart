import 'dart:math' as math;

import 'package:puffy_playground/src/common/grid.dart';

import 'game_pawn.dart';

// hardcoded into the generator
const _safeArea = 9;

GameSpec get sweepDefultGameSpec =>
    GameSpec(const BeeVector(16, 8), sweepDefaultBombs(16, 8));

int sweepDefaultBombs(int width, int height) {
  return math.max(sweepMaxBombs(width, height) ~/ 6, 1);
}

int sweepMaxBombs(int width, int height) {
  return math.max(width * height - _safeArea, 1);
}

class GameSpec {
  final BeeVector size;

  final int bombs;

  const GameSpec(this.size, this.bombs);

  int get width => size.x;

  int get height => size.y;

  bool get playable {
    final square = width * height;
    return square - _safeArea - bombs >= 0;
  }

  SweepGrid generateGrid(math.Random random, BeeVector startPoint) {
    final grid = SweepGrid(
      width > 0 ? width : 1,
      height > 0 ? height : 1,
      (_) => SweepPawn(),
    );
    if (!playable) {
      return grid;
    }
    final excluded = {startPoint, ...startPoint.neigboursX8};
    var remaining = bombs;
    while (remaining > 0) {
      final point = BeeVector(random.nextInt(width), random.nextInt(height));
      if (excluded.contains(point)) {
        continue;
      }
      remaining--;
      excluded.add(point);
      final cell = grid.cellAtPoint(point);
      cell.pawn.plantBomb();
      for (final neighbourCell in grid.neighbours8x(point)) {
        neighbourCell.pawn.recordNeigbourBomb();
      }
    }
    return grid;
  }
}
