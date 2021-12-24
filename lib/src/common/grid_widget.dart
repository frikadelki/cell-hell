import 'package:flutter/material.dart';
import 'package:puffy_playground/src/common/grid.dart';

class BeeGridWidget<TPawn> extends StatelessWidget {
  final BeeGrid<TPawn> grid;

  final Stream<void> updateSignal;

  final bool drawLegend;

  final Widget Function(BuildContext context, BeeCell<TPawn> cell) cellBuilder;

  const BeeGridWidget({
    Key? key,
    required this.grid,
    required this.updateSignal,
    this.drawLegend = false,
    required this.cellBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: updateSignal,
      builder: (context, _) {
        return _buildTable(context);
      },
    );
  }

  Widget _buildTable(BuildContext context) {
    final width = grid.width;
    final height = grid.height;
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
              ...Iterable.generate(width, (x) => _buildCell(context, x, y)),
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

  Widget _buildCell(BuildContext context, int x, int y) {
    final cell = grid.cell(x, y);
    return cellBuilder(context, cell);
  }
}
