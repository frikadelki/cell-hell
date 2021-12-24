import 'dart:math';

class Pair<F, S> {
  final F first;
  final S second;

  const Pair(this.first, this.second);

  @override
  int get hashCode {
    return 37 * first.hashCode + second.hashCode;
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! Pair<F, S>) {
      return false;
    }
    return other.first == first && other.second == second;
  }
}

class NumRange<T extends num> {
  final T? minValue;

  final T? maxValue;

  const NumRange(T? minValue, T? maxValue)
      : assert(minValue == null || maxValue == null || minValue <= maxValue),
        minValue = minValue,
        maxValue = minValue != null && maxValue != null && maxValue < minValue
            ? minValue
            : maxValue;

  bool get isOpenLeft => minValue == null;

  bool get isOpenRight => maxValue == null;

  bool get isOpen => isOpenLeft || isOpenRight;

  num clamp<E extends num>(E value) {
    num result = value;
    if (!isOpenLeft) {
      result = max(minValue!, result);
    }
    if (!isOpenRight) {
      result = min(maxValue!, result);
    }
    return result;
  }

  bool isInRange<E extends num>(E value) {
    if (!isOpenLeft && value < minValue!) {
      return false;
    }
    if (!isOpenRight && value > maxValue!) {
      return false;
    }
    return true;
  }

  double scaled(T value) {
    assert(!isOpen);
    if (isOpen) {
      return double.nan;
    }
    if (value < minValue!) {
      return 0;
    }
    if (value > maxValue!) {
      return 1.0;
    }
    if (minValue == maxValue) {
      return 1.0;
    }
    return (value - minValue!) / (maxValue! - minValue!);
  }
}

T todo<T>([String? message]) {
  throw UnimplementedError(message);
}

T noReturn<T>(Object e) {
  throw e;
}
