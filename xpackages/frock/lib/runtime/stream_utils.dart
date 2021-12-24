import 'dart:async';

import 'package:async/async.dart';
import 'package:frock/runtime/frock_runtime.dart';

import 'lifetime.dart';

abstract class ValueStreamRO<T> extends Stream<T> {
  T get value;
}

class ValueStream<T> extends ValueStreamRO<T> {
  final _controller = StreamController<T>.broadcast();

  T _value;

  ValueStream(this._value);

  factory ValueStream.lifetimed(Lifetime lifetime, T value) {
    final instance = ValueStream(value);
    lifetime.add(() {
      instance.close();
    });
    return instance;
  }

  void close() {
    _controller.close();
  }

  @override
  T get value => _value;

  set value(T newValue) {
    _value = newValue;
    _controller.add(newValue);
  }

  @override
  bool get isBroadcast => true;

  @override
  StreamSubscription<T> listen(
    void Function(T event)? onData, {
    Function? onError,
    dynamic Function()? onDone,
    bool? cancelOnError,
  }) {
    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class SignalStream extends Stream<void> {
  final _controller = StreamController<void>.broadcast();

  SignalStream();

  factory SignalStream.lifetimed(Lifetime lifetime) {
    final instance = SignalStream();
    lifetime.add(() {
      instance.close();
    });
    return instance;
  }

  void close() {
    _controller.close();
  }

  void signal() {
    _controller.add(null);
  }

  @override
  bool get isBroadcast => true;

  @override
  StreamSubscription<void> listen(
    void Function(void event)? onData, {
      Function? onError,
      dynamic Function()? onDone,
      bool? cancelOnError,
    }) {
    return _controller.stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

extension StreamLifetimesExt<TEvent> on Stream<TEvent> {
  void observe(Lifetime lifetime, void Function(TEvent) onData) {
    final subscription = listen(onData);
    lifetime.add(() {
      subscription.cancel();
    });
  }
}

extension StreamUtils<T> on Stream<T> {
  Stream<T> transformAllErrors(
      T Function(Object e, StackTrace stackTrace) transform) {
    final transformer = StreamTransformer<T, T>.fromHandlers(
      handleError: (e, stackTrace, sink) {
        final replacement = transform(e, stackTrace);
        sink.add(replacement);
      },
    );
    return this.transform(transformer);
  }
}

extension StreamOfStreams<T> on Stream<Iterable<Stream<T>>> {
  /// Resulting stream will emit events whenever this stream emits an event,
  /// or when any of the streams from the last event of this stream emit one
  Stream<void> mergeEach({Iterable<Stream<T>>? initialStreams}) {
    Stream<Iterable<Stream<T>>> stream() async* {
      if (initialStreams != null) {
        yield initialStreams;
      }
      yield* this;
    }

    return _MergeEach<T>(stream()).output;
  }
}

class _MergeEach<T> {
  final Stream<Iterable<Stream<T>>> _source;

  StreamController<void>? _output;

  StreamSubscription? _sourceSub;

  StreamSubscription? _mergedSub;

  _MergeEach(this._source) {
    _output = StreamController<void>(
      onListen: _startListenSource,
      onCancel: _cancelListenSource,
    );
  }

  Stream<void> get output => _output?.stream ?? noReturn(StateError('Closed'));

  void _startListenSource() {
    if (_output == null || _sourceSub != null || _mergedSub != null) {
      assert(false);
      return;
    }
    _sourceSub = _source.listen(_onSourceEvent, onDone: _onSourceDone);
  }

  void _cancelListenSource() async {
    if (_output == null) {
      assert(false);
      return;
    }
    await _cleanup();
  }

  void _onSourceEvent(Iterable<Stream<T>> event) async {
    if (_output == null || _sourceSub == null) {
      assert(false);
      return;
    }
    if (_mergedSub != null) {
      await _mergedSub!.cancel();
      _mergedSub = null;
    }
    _output!.add(null); // this is additional event to signal source change
    final mergedUpdate = StreamGroup.merge(event);
    _mergedSub = mergedUpdate.listen(_onMergedEvent);
  }

  void _onMergedEvent(T event) {
    _output!.add(null);
  }

  void _onSourceDone() async {
    if (_output == null || _sourceSub == null) {
      assert(false);
      return;
    }
    await _cleanup();
  }

  Future<void> _cleanup() async {
    if (_mergedSub != null) {
      await _mergedSub!.cancel();
      _mergedSub = null;
    }
    if (_sourceSub != null) {
      await _sourceSub!.cancel();
      _sourceSub = null;
    }
    assert(_output != null);
    if (_output != null) {
      await _output!.close();
      _output = null;
    }
  }
}
