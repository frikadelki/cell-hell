import 'package:cell_hell/src/common/grid.dart';
import 'package:frock/runtime/lifetime.dart';
import 'package:frock/runtime/stream_utils.dart';

import 'game_pawn.dart';
import 'game_spec.dart';

abstract class GameState {
  final GameSpec spec;

  GameState(this.spec);

  T visit<T>(GameStateVisitor<T> visitor);
}

class GameStateVisitor<T> {
  final T Function(EmptyGameState empty) empty;
  final T Function(RunningGameState running) running;
  final T Function(WonGameState win) completedWin;
  final T Function(LostGameState loss) completedLoss;

  GameStateVisitor({
    required this.empty,
    required this.running,
    required this.completedWin,
    required this.completedLoss,
  });
}

class EmptyGameState extends GameState {
  final void Function(GameSpec game, BeeVector startPoint) onStart;

  EmptyGameState(GameSpec spec, this.onStart) : super(spec);

  void start(BeeVector startPoint) {
    onStart(spec, startPoint);
  }

  @override
  T visit<T>(GameStateVisitor<T> visitor) => visitor.empty(this);
}

class RunningGameState extends GameState {
  final SweepGrid grid;

  final gridUpdateSignal = SignalStream();

  final remainingFlagsProperty = ValueStream<int>(0);

  final DateTime startTime;

  final void Function(CompletedGameState completed) onCompleted;

  bool _completed = false;

  RunningGameState.start(
    Lifetime lifetime,
    GameSpec spec,
    this.grid,
    this.startTime,
    this.onCompleted,
  ) : super(spec) {
    lifetime.add(() {
      gridUpdateSignal.close();
      remainingFlagsProperty.close();
    });
    remainingFlagsProperty.value = spec.bombs;
  }

  Duration get duration => DateTime.now().difference(startTime);

  void invertFlag(BeeVector point) {
    if (_completed) {
      assert(false);
      return;
    }
    final cell = grid.cellAtPoint(point);
    if (cell.pawn.openend) {
      return;
    }
    if (cell.pawn.flagged) {
      remainingFlagsProperty.value++;
    } else {
      if (remainingFlagsProperty.value <= 0) {
        return;
      }
      remainingFlagsProperty.value--;
    }
    cell.pawn.invertFlag();
    gridUpdateSignal.signal();
  }

  void openPawn(BeeVector point) {
    if (_completed) {
      assert(false);
      return;
    }
    final cell = grid.cellAtPoint(point);
    final pawn = cell.pawn;
    if (pawn.openend || pawn.flagged) {
      return;
    }
    final clearedFlags = grid.openPawnRecursive(cell);
    remainingFlagsProperty.value += clearedFlags;
    gridUpdateSignal.signal();
    if (pawn.hasBomb) {
      _endGameLost();
    } else {
      _checkGameWin();
    }
  }

  void _checkGameWin() {
    assert(!_completed);
    final closedCells = grid.cells.where((cell) => !cell.pawn.openend).length;
    if (spec.bombs == closedCells) {
      _completed = true;
      onCompleted(WonGameState(spec, grid, duration));
    }
  }

  void _endGameLost() {
    assert(!_completed);
    _completed = true;
    _revealGrid();
    onCompleted(LostGameState(spec, grid, duration));
  }

  void _revealGrid() {
    grid.revealGrid();
    gridUpdateSignal.signal();
  }

  @override
  T visit<T>(GameStateVisitor<T> visitor) => visitor.running(this);
}

abstract class CompletedGameState extends GameState {
  final SweepGrid grid;

  final Duration time;

  CompletedGameState(GameSpec spec, this.grid, this.time) : super(spec);
}

class WonGameState extends CompletedGameState {
  WonGameState(GameSpec spec, SweepGrid grid, Duration time)
      : super(spec, grid, time);

  @override
  T visit<T>(GameStateVisitor<T> visitor) => visitor.completedWin(this);
}

class LostGameState extends CompletedGameState {
  LostGameState(GameSpec spec, SweepGrid grid, Duration time)
      : super(spec, grid, time);

  @override
  T visit<T>(GameStateVisitor<T> visitor) => visitor.completedLoss(this);
}
