import 'package:puffy_playground/src/common/grid.dart';

abstract class LifePawnRO {
  bool get alive;

  int get generation;
}

typedef LifeCellRO = BeeCell<LifePawnRO>;

typedef LifeCell = BeeCell<LifePawn>;

typedef LifeGridRO = BeeGrid<LifePawnRO>;

typedef LifeGrid = BeeGrid<LifePawn>;

class LifePawn implements LifePawnRO {
  int _generation = 0;

  bool _next = false;

  @override
  bool get alive => _generation > 0;

  @override
  int get generation => _generation;

  set alive(bool alive) {
    if (alive) {
      _generation = 1;
    } else {
      _generation = 0;
    }
  }

  void dayStep(LifeGrid grid, LifeCell myCell) {
    final neighbours = grid.neighbours8x(myCell.point);
    final aliveCount = neighbours.where((it) => it.pawn.alive).length;
    _next = false;
    if (alive) {
      if (2 == aliveCount || 3 == aliveCount) {
        _next = true;
      }
    } else {
      if (3 == aliveCount) {
        _next = true;
      }
    }
  }

  void nightStep(LifeGrid grid, LifeCell myCell) {
    if (_next) {
      _generation++;
    } else {
      _generation = 0;
    }
  }
}
