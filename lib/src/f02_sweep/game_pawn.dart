import 'package:cell_hell/src/common/grid.dart';

enum SweepPawnState {
  bomb,
  empty,
}

abstract class SweepPawnRO {
  SweepPawnState get state;

  bool get openend;

  bool get flagged;

  int get neighbourBombs;
}

extension SweepPawnROExt on SweepPawnRO {
  bool get hasBomb => SweepPawnState.bomb == state;

  bool get hasNeighbourBombs => neighbourBombs > 0;
}

class SweepPawn implements SweepPawnRO {
  SweepPawnState _state = SweepPawnState.empty;

  bool _open = false;

  bool _flagged = false;

  int _neighbourBombs = 0;

  @override
  SweepPawnState get state => _state;

  void clear() {
    _state = SweepPawnState.empty;
    _open = false;
    _flagged = false;
    _neighbourBombs = 0;
  }

  void plantBomb() {
    assert(SweepPawnState.empty == _state);
    _state = SweepPawnState.bomb;
  }

  @override
  bool get flagged => _flagged;

  void invertFlag() {
    _flagged = !flagged;
  }

  @override
  int get neighbourBombs => _neighbourBombs;

  void recordNeigbourBomb() {
    _neighbourBombs++;
  }

  @override
  bool get openend => _open;

  void markOpen() {
    assert(!_open);
    _open = true;
  }
}

typedef SweepCellRO = BeeCell<SweepPawnRO>;

typedef SweepCell = BeeCell<SweepPawn>;

typedef SweepGridRO = BeeGrid<SweepPawnRO>;

typedef SweepGrid = BeeGrid<SweepPawn>;

extension SweepGridOps on SweepGrid {
  /// returns amount of cleared flags on opened cells
  int openPawnRecursive(SweepCell cell) {
    assert(!cell.pawn.openend);
    final wasFlagged = cell.pawn.flagged;
    cell.pawn.markOpen();
    if (wasFlagged) {
      cell.pawn.invertFlag();
    }
    var flagsReset = wasFlagged ? 1 : 0;
    if (cell.pawn.hasBomb || cell.pawn.hasNeighbourBombs) {
      return flagsReset;
    }
    final neighbours = neighbours8x(cell.point).where((it) => !it.pawn.openend);
    for (final neighbour in neighbours) {
      flagsReset += openPawnRecursive(neighbour);
    }
    return flagsReset;
  }

  void revealGrid() {
    for (final cell in cells) {
      if (!cell.pawn.openend) {
        cell.pawn.markOpen();
      }
    }
  }
}
