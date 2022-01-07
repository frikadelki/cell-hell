import 'vector2.dart';

export 'vector2.dart';

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
