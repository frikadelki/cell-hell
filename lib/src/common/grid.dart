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

class BeeCell<TPawn> {
  final BeeVector point;

  final TPawn pawn;

  BeeCell(this.point, this.pawn);

  int get x => point.x;

  int get y => point.y;
}

class BeeGrid<TPawn> {
  final int width;

  final int height;

  late final List<List<BeeCell<TPawn>>> _grid;

  BeeGrid(this.width, this.height, TPawn Function(BeeVector point) pawn) {
    BeeCell<TPawn> cell(int x, int y) {
      final point = BeeVector(x, y);
      return BeeCell<TPawn>(point, pawn(point));
    }

    List<BeeCell<TPawn>> column(int x) {
      return List.generate(
        height,
        (y) => cell(x, y),
        growable: false,
      );
    }

    _grid = List.generate(
      width,
      (x) => column(x),
      growable: false,
    );
  }

  Iterable<BeeCell<TPawn>> get cells sync* {
    for (var x = 0; x < width; x++) {
      final column = _grid[x];
      for (var y = 0; y < height; y++) {
        yield column[y];
      }
    }
  }

  BeeCell<TPawn> cell(int x, int y) {
    return _grid[x][y];
  }

  BeeCell<TPawn> cellAtPoint(BeeVector point) {
    return _grid[point.x][point.y];
  }

  Iterable<BeeCell<TPawn>> neighbours8x(BeeVector point) {
    return point.neigboursX8.map((neighbourPoint) {
      if (pointInside(neighbourPoint)) {
        return cellAtPoint(neighbourPoint);
      } else {
        return null;
      }
    }).whereType();
  }

  void forEachRow(void Function(int row, Iterable<BeeCell> cells) visit) {
    for (var y = 0; y < height; y++) {
      final cells = Iterable.generate(width, (x) => _grid[x][y]);
      visit(y, cells);
    }
  }

  void forEachColumn(void Function(int column, Iterable<BeeCell> cells) visit) {
    for (var x = 0; x < width; x++) {
      final cells = _grid[x];
      visit(x, cells);
    }
  }

  bool _checkX(int x) {
    return x >= 0 && x < width;
  }

  bool _checkY(int y) {
    return y >= 0 && y < height;
  }

  bool pointInside(BeeVector point) {
    return _checkX(point.x) && _checkY(point.y);
  }
}
