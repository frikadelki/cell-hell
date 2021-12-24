import 'dart:math' as math;

import 'package:frock/runtime/lifetime.dart';
import 'package:frock/runtime/stream_utils.dart';
import 'package:puffy_playground/src/common/grid.dart';
import 'package:puffy_playground/src/f01_life/pawn.dart';

class LifeGame {
  static const _stepDelay = Duration(milliseconds: 500);

  final Lifetime _lifetime;

  final BeeGrid<LifePawn> _grid;

  final _gridUpdatedSignal = SignalStream();

  final _runningStream = ValueStream<bool>(false);

  final _random = math.Random();

  LifeGame(this._lifetime, int width, int height)
      : _grid = BeeGrid(width, height, _pawn) {
    _lifetime.add(() {
      _gridUpdatedSignal.close();
      _runningStream.close();
    });
    _run();
  }

  static LifePawn _pawn(BeeVector point) {
    return LifePawn();
  }

  Stream<void> get gridUpdatedSignal => _gridUpdatedSignal;

  BeeGrid<LifePawnRO> get grid => _grid;

  void clearGrid() {
    for (final cell in _grid.cells) {
      cell.pawn.alive = false;
    }
    _gridUpdatedSignal.signal();
  }

  void randomizeGrid() {
    for (final cell in _grid.cells) {
      cell.pawn.alive = _random.nextBool();
    }
    _gridUpdatedSignal.signal();
  }

  void invertPawn(int x, int y) {
    final pawn = _grid.cell(x, y).pawn;
    pawn.alive = !pawn.alive;
    _gridUpdatedSignal.signal();
  }

  ValueStreamRO<bool> get runningStream => _runningStream;

  void togglePlay() {
    _runningStream.value = !_runningStream.value;
  }

  void _run() async {
    while (!_lifetime.isTerminated) {
      if (!_runningStream.value) {
        await for (final running in _runningStream) {
          if (running) {
            break;
          }
        }
        await Future<void>.delayed(_stepDelay);
        continue;
      }
      for (final cell in _grid.cells) {
        cell.pawn.dayStep(_grid, cell);
      }
      for (final cell in _grid.cells) {
        cell.pawn.nightStep(_grid, cell);
      }
      _gridUpdatedSignal.signal();
      await Future<void>.delayed(_stepDelay);
    }
  }
}
