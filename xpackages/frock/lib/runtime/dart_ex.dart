import 'utils.dart';

extension NumIterableEx<T extends num> on Iterable<T> {
  T sum() {
    if (isEmpty) {
      if (T == int) {
        return 0 as T;
      } else if (T == double) {
        return 0.0 as T;
      } else {
        throw UnsupportedError("Unknown num type '$T'.");
      }
    }
    return reduce((t1, t2) => (t1 + t2) as T);
  }

  double average() {
    return sum().toDouble() / length;
  }
}

extension IterableEx<T> on Iterable<T> {
  Iterable<K> mapIndexed<K>(IndexedTransform<T, K> transform) {
    return IndexMappedIterable(this, transform);
  }

  String mapJoin(String Function(T item) transform, [String separator = '']) {
    return map(transform).join(separator);
  }

  T anyMin(num Function(T item) eval) {
    return allMin(eval).first;
  }

  Iterable<T> allMin(num Function(T item) eval) {
    final results = <T>[];
    num? min;
    for (final item in this) {
      final itemW = eval(item);
      if (min == null || itemW < min) {
        results.clear();
        results.add(item);
        min = itemW;
      } else if (itemW == min) {
        results.add(item);
      }
    }
    return results;
  }

  Iterable<T> allMax(num Function(T item) eval) {
    final results = <T>[];
    num? max;
    for (final item in this) {
      final itemW = eval(item);
      if (max == null || itemW > max) {
        results.clear();
        results.add(item);
        max = itemW;
      } else if (itemW == max) {
        results.add(item);
      }
    }
    return results;
  }

  bool isDistinct<TKey>(TKey Function(T it) keySelector) {
    final checkSet = <TKey>{};
    for (final it in this) {
      final itKey = keySelector(it);
      if (checkSet.contains(itKey)) {
        return false;
      } else {
        checkSet.add(itKey);
      }
    }
    return true;
  }

  void assertIsDistinct<TKey>(
    TKey Function(T it) keySelector, {
    Exception? toThrow = const FormatException('Elements are not distinct.'),
  }) {
    if (isDistinct(keySelector)) {
      return;
    }
    assert(false, 'Duplicated elements.');
    if (null != toThrow) {
      throw toThrow;
    }
  }
}

typedef IndexedTransform<TIn, TOut> = TOut Function(TIn item, int index);

class IndexMappedIterable<TIn, TOut> extends Iterable<TOut> {
  final Iterable<TIn> _source;

  final IndexedTransform<TIn, TOut> _transform;

  IndexMappedIterable(this._source, this._transform);

  @override
  Iterator<TOut> get iterator =>
      IndexMappedIterator(_source.iterator, _transform);
}

class IndexMappedIterator<TIn, TOut> extends Iterator<TOut> {
  final Iterator<TIn> _source;

  final IndexedTransform<TIn, TOut> _transform;

  TOut? _current;

  int index = -1;

  IndexMappedIterator(this._source, this._transform);

  @override
  TOut get current => _current ?? noReturn(StateError('Out of range.'));

  @override
  bool moveNext() {
    if (_source.moveNext()) {
      index++;
      _current = _transform(_source.current, index);
      return true;
    }
    index = -1;
    _current = null;
    return false;
  }
}

extension NestedIterablesEx<T> on Iterable<Iterable<T>> {
  Iterable<T> flatten() => expand((ts) => ts);

  Iterable<TOut> flatMap<TOut>(TOut Function(T) mapper) =>
      flatten().map(mapper);
}

extension MapExt<TKey, TValue> on Map<TKey, TValue> {
  TValue getOrPut(TKey key, TValue Function(TKey key) defaultCalc) {
    if (containsKey(key)) {
      return this[key]!;
    } else {
      final value = defaultCalc(key);
      this[key] = value;
      return value;
    }
  }
}

extension StringExt on String {
  String capitalizeEachWord() {
    final builder = StringBuffer();
    var sawWhitespace = true;
    for (var i = 0; i < length; i++) {
      final char = this[i];
      final whitespace = char.trim() == '';
      if (whitespace) {
        builder.write(char);
        sawWhitespace = true;
      } else {
        if (sawWhitespace) {
          builder.write(char.toUpperCase());
          sawWhitespace = false;
        } else {
          builder.write(char);
        }
      }
    }
    return builder.toString();
  }
}

extension NullsafetyHelpers<T> on T {
  R let<R>(R Function(T it) code) => code(this);
}
