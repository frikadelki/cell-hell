import 'package:flutter/material.dart';
import 'package:puffy_playground/src/common/grid.dart';

class BeeGridWidget<TPawn> extends StatelessWidget {
  final BeeGrid<TPawn> grid;

  final bool drawLegend;

  final Widget Function(BuildContext context, BeeCell<TPawn> cell) cellBuilder;

  const BeeGridWidget({
    Key? key,
    required this.grid,
    this.drawLegend = false,
    required this.cellBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationAspectGridWidget(
      width: grid.width,
      height: grid.height,
      drawLegend: drawLegend,
      cellBuilder: _buildCell,
    );
  }

  Widget _buildCell(BuildContext context, int x, int y) {
    final cell = grid.cell(x, y);
    return cellBuilder(context, cell);
  }
}

class OrientationAspectGridWidget extends StatelessWidget {
  final int width;

  final int height;

  final bool drawLegend;

  final Widget Function(BuildContext context, int x, int y) cellBuilder;

  const OrientationAspectGridWidget({
    Key? key,
    required this.width,
    required this.height,
    this.drawLegend = false,
    required this.cellBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final lanscapeMatch =
            Orientation.landscape == orientation && width >= height;
        final portraitMatch =
            Orientation.portrait == orientation && height >= width;
        final orientationMatch = lanscapeMatch || portraitMatch;
        final tw = orientationMatch ? width : height;
        final th = orientationMatch ? height : width;
        return AspectRatio(
          aspectRatio: tw / th,
          child: RawGridWidget(
            width: tw,
            height: th,
            cellBuilder: (context, x, y) {
              return orientationMatch
                  ? cellBuilder(context, x, y)
                  : cellBuilder(context, y, x);
            },
          ),
        );
      },
    );
  }
}

class RawGridWidget extends StatelessWidget {
  final int width;

  final int height;

  final bool drawLegend;

  final Widget Function(BuildContext context, int x, int y) cellBuilder;

  const RawGridWidget({
    Key? key,
    required this.width,
    required this.height,
    this.drawLegend = false,
    required this.cellBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      defaultColumnWidth: const FlexColumnWidth(),
      columnWidths: <int, TableColumnWidth>{
        if (drawLegend) ...{
          0: const FixedColumnWidth(16),
          width + 1: const FixedColumnWidth(16),
        },
      },
      children: <TableRow>[
        if (drawLegend) ...[
          TableRow(
            children: <Widget>[
              _buildHeaderSpacer(),
              ...Iterable.generate(width, (x) => _buildHeaderLabel(x)),
              _buildHeaderSpacer(),
            ],
          ),
        ],
        ...Iterable.generate(height, (y) {
          return TableRow(
            children: <Widget>[
              if (drawLegend) ...[
                _buildHeaderLabel(y),
              ],
              ...Iterable.generate(width, (x) => cellBuilder(context, x, y)),
              if (drawLegend) ...[
                _buildHeaderSpacer(),
              ],
            ],
          );
        }),
      ],
    );
  }

  Widget _buildHeaderLabel(int n) {
    return Center(
      child: Text('$n'),
    );
  }

  Widget _buildHeaderSpacer() {
    return const SizedBox.shrink();
  }
}
