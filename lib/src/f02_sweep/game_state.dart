class GameSpec {
  final int width;

  final int height;

  final int bombs;

  const GameSpec(this.width, this.height, this.bombs);
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
