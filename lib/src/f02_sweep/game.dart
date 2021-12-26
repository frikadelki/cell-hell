import 'dart:math' as math;

import 'package:frock/frock.dart';
import 'package:puffy_playground/src/common/grid.dart';

import 'game_state.dart';
import 'game_pawn.dart';

class SweepGame {
  static const _defaultGameSpec = GameSpec(10, 10, 13);

  final Lifetime _lifetime;

  final _random = math.Random();

  GameSpec _gameSpec = _defaultGameSpec;

  final _gameStateStream = ValueStream<GameState>(EmptyGameState());

  var _grid = _buildGrid(_defaultGameSpec);

  final _gridUpdatedSignal = SignalStream();

  final _remainingFlags = ValueStream<int>(_defaultGameSpec.bombs);

  DateTime _gameStartTime = DateTime.fromMicrosecondsSinceEpoch(0);

  SweepGame(this._lifetime, int width, int height) {
    _lifetime.add(() {
      _gameStateStream.close();
      _gridUpdatedSignal.close();
      _remainingFlags.close();
    });
  }

  static SweepGrid _buildGrid(GameSpec spec) {
    return SweepGrid(
      _defaultGameSpec.width,
      _defaultGameSpec.height,
      (_) => SweepPawn(),
    );
  }

  void _generateBombs(BeeVector startPoint) {
    final excluded = {startPoint, ...startPoint.neigboursX8};
    var remaining = _gameSpec.bombs;
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

  ValueStreamRO<GameState> get gameStateStream => _gameStateStream;

  SweepGridRO get grid => _grid;

  Stream<void> get gridUpdatedSignal => _gridUpdatedSignal;

  ValueStreamRO<int> get remainingFlags => _remainingFlags;

  Duration get gameDuration => DateTime.now().difference(_gameStartTime);

  void restartGame([GameSpec? gameSpec]) {
    _gameStateStream.value = EmptyGameState();
    if (gameSpec != null) {
      _gameSpec = gameSpec;
      _grid = _buildGrid(gameSpec);
    }
    for (final cell in _grid.cells) {
      cell.pawn.clear();
    }
    _remainingFlags.value = _gameSpec.bombs;
    _gridUpdatedSignal.signal();
  }

  void forfeit() {
    if (_gameStateStream.value is! RunningGameState) {
      return;
    }
    _endGameLost();
  }

  void invertFlag(SweepCellRO cell) {
    cell as SweepCell;
    if (_gameStateStream.value is! RunningGameState) {
      return;
    }
    if (cell.pawn.openend || remainingFlags.value <= 0) {
      return;
    }
    if (cell.pawn.flagged) {
      _remainingFlags.value++;
    } else {
      _remainingFlags.value--;
    }
    cell.pawn.invertFlag();
    _gridUpdatedSignal.signal();
  }

  void openPawn(SweepCellRO cell) {
    cell as SweepCell;
    if (_gameStateStream.value is EmptyGameState) {
      _generateBombs(cell.point);
      _gameStartTime = DateTime.now();
      _gridUpdatedSignal.signal();
      _gameStateStream.value = RunningGameState();
    }
    final pawn = cell.pawn;
    if (pawn.openend || pawn.flagged) {
      return;
    }
    _openPawnRecursive(cell);
    _gridUpdatedSignal.signal();
    if (pawn.hasBomb) {
      _endGameLost();
    } else {
      _checkGameWin();
    }
  }

  void _openPawnRecursive(SweepCell cell) {
    assert(!cell.pawn.openend);
    cell.pawn.markOpen();
    if (cell.pawn.hasBomb || cell.pawn.hasNeighbourBombs) {
      return;
    }
    final neighbours =
        _grid.neighbours8x(cell.point).where((it) => !it.pawn.openend);
    for (final neighbour in neighbours) {
      _openPawnRecursive(neighbour);
    }
  }

  void _checkGameWin() {
    assert(_gameStateStream.value is! CompletedGameState);
    final closedCells = _grid.cells.where((cell) => !cell.pawn.openend).length;
    if (_gameSpec.bombs == closedCells) {
      _gameStateStream.value = WonGameState(_gameSpec, gameDuration);
    }
  }

  void _endGameLost() {
    assert(_gameStateStream.value is! CompletedGameState);
    _revealGrid();
    _gameStateStream.value = LostGameState(_gameSpec, gameDuration);
  }

  void _revealGrid() {
    for (final cell in _grid.cells) {
      if (!cell.pawn.openend) {
        cell.pawn.markOpen();
      }
    }
    _gridUpdatedSignal.signal();
  }
}
