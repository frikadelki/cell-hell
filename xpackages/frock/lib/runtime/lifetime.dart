typedef LifetimeCleanupHandler = void Function();

abstract class Lifetime {
  bool get isTerminated;

  void add(LifetimeCleanupHandler handler);

  void remove(LifetimeCleanupHandler handler);
}

abstract class MutableLifetime implements Lifetime {
  void terminate();
}

class PlainLifetime implements MutableLifetime {
  var _terminated = false;

  @override
  bool get isTerminated => _terminated;

  final _cleanupHandlers = <LifetimeCleanupHandler>[];

  PlainLifetime();

  PlainLifetime.nested(Lifetime lifetime) {
    lifetime.add(terminate);
    add(() => lifetime.remove(terminate));
  }

  @override
  void add(LifetimeCleanupHandler handler) {
    assert(!_terminated);
    if (_terminated) {
      return;
    }
    _cleanupHandlers.add(handler);
  }

  @override
  void remove(LifetimeCleanupHandler handler) {
    if (_terminated) {
      return;
    }
    _cleanupHandlers.remove(handler);
  }

  @override
  void terminate() {
    assert(!_terminated);
    if (_terminated) {
      return;
    }
    _terminated = true;
    final cleanup = _cleanupHandlers.reversed.toList(growable: false);
    _cleanupHandlers.clear();
    cleanup.forEach((handler) => handler());
  }
}

class PlainLifetimesSequence {
  final Lifetime lifetime;

  MutableLifetime? _current;

  PlainLifetimesSequence(this.lifetime) {
    lifetime.add(() => _current = null);
  }

  Lifetime next() {
    if (lifetime.isTerminated) {
      throw StateError('Source lifetime already terminated.');
    }
    final next = PlainLifetime.nested(lifetime);
    _current?.terminate();
    _current = next;
    return next;
  }

  void clear() {
    _current?.terminate();
    _current = null;
  }
}

class PlainLifetimesAutoSequence {
  late final PlainLifetime _lifetime;

  late final PlainLifetimesSequence _sequence;

  PlainLifetimesAutoSequence() {
    _lifetime = PlainLifetime();
    _sequence = PlainLifetimesSequence(_lifetime);
  }

  Lifetime get lifetime => _lifetime;

  Lifetime next() => _sequence.next();

  void clear() => _sequence.clear();

  void terminate() => _lifetime.terminate();
}
