import 'dart:async';

import 'lifetime.dart';
import 'stream_utils.dart';

class RepeatableSyncState<TData> {
  final TData? data;

  final bool syncing;

  RepeatableSyncState(this.data, this.syncing);

  RepeatableSyncState.initial()
      : data = null,
        syncing = false;
}

abstract class RepeatableSyncFetch<TData> {
  Future<TData> fetch();
}

class RepeatableSyncFetchDelegate<TData> implements RepeatableSyncFetch<TData> {
  final Future<TData> Function() _fetch;

  RepeatableSyncFetchDelegate(this._fetch);

  @override
  Future<TData> fetch() {
    return _fetch();
  }
}

class RepeatableSync<TData> {
  final Lifetime _lifetime;

  final PlainLifetimesSequence _applyLifetimes;

  final _stream =
      ValueStream<RepeatableSyncState<TData>>(RepeatableSyncState.initial());

  RepeatableSync(this._lifetime)
      : _applyLifetimes = PlainLifetimesSequence(_lifetime) {
    _lifetime.add(() {
      _stream.close();
    });
  }

  RepeatableSyncState<TData> get state => _stream.value;

  Stream<void> get updates => _stream;

  void applyOptimistic(TData data) {
    if (_lifetime.isTerminated) {
      assert(!_lifetime.isTerminated);
      return;
    }
    _applyLifetimes.next();
    _stream.value = RepeatableSyncState(data, false);
  }

  Future<void> applyFetch(RepeatableSyncFetch<TData> fetch) {
    if (_lifetime.isTerminated) {
      assert(!_lifetime.isTerminated);
      return Future.value();
    }
    final lifetime = _applyLifetimes.next();
    final completer = Completer<void>();
    lifetime.add(() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    _fetch(lifetime, completer, fetch);
    return completer.future;
  }

  void _fetch(
    Lifetime lifetime,
    Completer<void> completer,
    RepeatableSyncFetch<TData> fetch,
  ) async {
    try {
      _stream.value = RepeatableSyncState(_stream.value.data, true);
      final newData = await fetch.fetch();
      if (completer.isCompleted) {
        return;
      }
      _stream.value = RepeatableSyncState(newData, false);
    } catch (_) {
      if (!completer.isCompleted) {
        _stream.value = RepeatableSyncState(_stream.value.data, false);
      }
    } finally {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }
}
