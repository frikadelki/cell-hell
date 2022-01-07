import 'dart:math' as math;

import 'package:frock/frock.dart';
import 'package:puffy_playground/src/common/grid.dart';

import 'game_spec.dart';
import 'game_state.dart';

class SweepGame {
  final Lifetime _lifetime;

  final PlainLifetimesSequence _gamesLifetimes;

  final _random = math.Random();

  late final ValueStream<GameState> _gameStateStream;

  SweepGame(this._lifetime, GameSpec defaultSpec)
      : _gamesLifetimes = PlainLifetimesSequence(_lifetime) {
    _gameStateStream = ValueStream(_emptyState(defaultSpec));
    _lifetime.add(() {
      _gameStateStream.close();
    });
  }

  EmptyGameState _emptyState(GameSpec spec) => EmptyGameState(spec, _onStart);

  ValueStreamRO<GameState> get gameStateStream => _gameStateStream;

  void restartGame([GameSpec? gameSpec]) {
    gameSpec = gameSpec ?? _gameStateStream.value.spec;
    if (!gameSpec.playable) {
      return;
    }
    _gameStateStream.value = _emptyState(gameSpec);
  }

  void _onStart(GameSpec spec, BeeVector startPoint) {
    assert(_gameStateStream.value is EmptyGameState);
    final grid = spec.generateGrid(_random, startPoint);
    final gameLifetime = _gamesLifetimes.next();
    final state = RunningGameState.start(
        gameLifetime, spec, grid, DateTime.now(), _onCompleted);
    _gameStateStream.value = state;

    state.openPawn(startPoint);
  }

  void _onCompleted(CompletedGameState completed) {
    assert(_gameStateStream.value is RunningGameState);
    _gameStateStream.value = completed;
  }
}
