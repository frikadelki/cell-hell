class BeeVector {
  final int x;

  final int y;

  const BeeVector(this.x, this.y);

  BeeVector operator +(BeeVector b) {
    return BeeVector(x + b.x, y + b.y);
  }

  @override
  int get hashCode {
    return 37 * x.hashCode + y.hashCode;
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is BeeVector && other.x == x && other.y == y);
  }
}

class BeeGridDirections {
  static const west = BeeVector(-1, 0);
  static const northWest = BeeVector(-1, 1);
  static const north = BeeVector(0, 1);
  static const northEast = BeeVector(1, 1);
  static const east = BeeVector(1, 0);
  static const southEast = BeeVector(1, -1);
  static const south = BeeVector(0, -1);
  static const southWest = BeeVector(-1, -1);

  static const neigboursX4 = [
    west,
    north,
    east,
    south,
  ];

  static const neigboursX8 = [
    west,
    northWest,
    north,
    northEast,
    east,
    southEast,
    south,
    southWest,
  ];
}

extension BeePointNeigbours on BeeVector {
  Iterable<BeeVector> get neigboursX4 {
    return BeeGridDirections.neigboursX4.map((direction) => this + direction);
  }

  Iterable<BeeVector> get neigboursX8 {
    return BeeGridDirections.neigboursX8.map((direction) => this + direction);
  }
}
