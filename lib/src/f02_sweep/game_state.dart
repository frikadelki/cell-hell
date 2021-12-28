import 'dart:math' as math;

import 'package:puffy_playground/src/common/grid.dart';

GameSpec get sweepDefultGameSpec =>
    GameSpec(const BeeVector(8, 8), sweepDefaultBombs(8, 8));

// hardcoded into the generator
const _safeArea = 9;

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
}

int sweepDefaultBombs(int width, int height) {
  return math.max(sweepMaxBombs(width, height) ~/ 6, 1);
}

int sweepMaxBombs(int width, int height) {
  return math.max(width * height - _safeArea, 1);
}

abstract class GameState {
  T visit<T>(GameStateVisitor<T> visitor);
}

class GameStateVisitor<T> {
  final T Function() empty;
  final T Function() running;
  final T Function(WonGameState win) completedWin;
  final T Function(LostGameState loss) completedLoss;

  GameStateVisitor({
    required this.empty,
    required this.running,
    required this.completedWin,
    required this.completedLoss,
  });
}

class EmptyGameState implements GameState {
  @override
  T visit<T>(GameStateVisitor<T> visitor) => visitor.empty();
}

class RunningGameState implements GameState {
  @override
  T visit<T>(GameStateVisitor<T> visitor) => visitor.running();
}

abstract class CompletedGameState implements GameState {
  final GameSpec spec;

  final Duration time;

  CompletedGameState(this.spec, this.time);
}

class WonGameState extends CompletedGameState {
  WonGameState(GameSpec spec, Duration time) : super(spec, time);

  @override
  T visit<T>(GameStateVisitor<T> visitor) => visitor.completedWin(this);
}

class LostGameState extends CompletedGameState {
  LostGameState(GameSpec spec, Duration time) : super(spec, time);

  @override
  T visit<T>(GameStateVisitor<T> visitor) => visitor.completedLoss(this);
}
