import 'dart:math' as math;

import 'package:frock/runtime/lifetime.dart';
import 'package:frock/runtime/stream_utils.dart';
import 'package:puffy_playground/src/common/grid.dart';

import 'pawn.dart';

class SweepGame {
  static const _mines = 25;

  final Lifetime _lifetime;

  final SweepGrid _grid;

  bool _generated = false;

  final _gridUpdatedSignal = SignalStream();

  final _random = math.Random();

  SweepGame(this._lifetime, int width, int height)
      : _grid = SweepGrid(width, height, _pawn) {
    _lifetime.add(() {
      _gridUpdatedSignal.close();
    });
  }

  static SweepPawn _pawn(BeeVector point) {
    return SweepPawn();
  }

  Stream<void> get gridUpdatedSignal => _gridUpdatedSignal;

  SweepGridRO get grid => _grid;

  void clearGrid() {
    for (final cell in _grid.cells) {
      cell.pawn.clear();
    }
    _generated = false;
    _gridUpdatedSignal.signal();
  }

  void revealGrid() {
    for (final cell in _grid.cells) {
      if (!cell.pawn.openend) {
        cell.pawn.markOpen();
      }
    }
    _gridUpdatedSignal.signal();
  }

  void openPawn(int x, int y) {
    final cell = _grid.cell(x, y);
    final point = cell.point;
    if (!_generated) {
      _generate(point);
      _generated = true;
    }
    final pawn = cell.pawn;
    if (pawn.openend) {
      return;
    }
    _openCellRecursive(cell);
    // TODO: game end
    _gridUpdatedSignal.signal();
  }

  void _generate(BeeVector startPoint) {
    final excluded = {startPoint, ...startPoint.neigboursX8};
    var remaining = _mines;
    while (remaining > 0) {
      final point = BeeVector(
        _random.nextInt(_grid.width),
        _random.nextInt(_grid.height),
      );
      if (excluded.contains(point)) {
        continue;
      }
      remaining--;
      excluded.add(point);
      final cell = _grid.cellAtPoint(point);
      cell.pawn.plantBomb();
      for (final neighbourCell in _grid.neighbours8x(point)) {
        neighbourCell.pawn.recordNeigbourBomb();
      }
    }
  }

  void _openCellRecursive(SweepCell cell) {
    assert(!cell.pawn.openend);
    cell.pawn.markOpen();
    if (cell.pawn.hasBomb || cell.pawn.hasNeighbourBombs) {
      return;
    }
    final neighbours =
        _grid.neighbours8x(cell.point).where((it) => !it.pawn.openend);
    for (final neighbour in neighbours) {
      _openCellRecursive(neighbour);
    }
  }
}
