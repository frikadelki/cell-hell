import 'package:flutter/material.dart';
import 'package:puffy_playground/src/common/cell_widget.dart';
import 'package:puffy_playground/src/common/grid_widget.dart';

import 'game_pawn.dart';

class SweepGridWidget extends StatelessWidget {
  final SweepGridRO grid;

  final Stream<void> updateSignal;

  final void Function(SweepCellRO cell) onCellPressed;

  final void Function(SweepCellRO cell) onCellLongPressed;

  const SweepGridWidget({
    Key? key,
    required this.grid,
    required this.updateSignal,
    required this.onCellPressed,
    required this.onCellLongPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeeGridWidget<SweepPawnRO>(
      grid: grid,
      updateSignal: updateSignal,
      cellBuilder: (context, cell) {
        return SweepCellWidget(
          cell: cell,
          onPressed: () => onCellPressed(cell),
          onLongPressed: () => onCellLongPressed(cell),
        );
      },
    );
  }
}

/// '✺' : '♣';
/// '✘' : '♣';
class SweepCellWidget extends StatelessWidget {
  final SweepCellRO cell;

  final VoidCallback onPressed;

  final VoidCallback onLongPressed;

  const SweepCellWidget({
    Key? key,
    required this.cell,
    required this.onPressed,
    required this.onLongPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const closedBg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        Colors.blueGrey,
        Colors.grey,
      ],
    );

    Gradient openEmptyBg(Color base) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          base,
          Colors.white,
        ],
      );
    }

    final openBombBg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        Colors.brown.shade300,
        Colors.brown.shade200,
      ],
    );

    final bombsCountColors = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.green.shade300,
      Colors.yellow.shade300,
      Colors.yellow.shade700,
      Colors.orange.shade500,
      Colors.orange.shade800,
      Colors.red.shade500,
      Colors.red.shade800,
    ];
    late final Gradient bg;
    if (!cell.pawn.openend) {
      bg = closedBg;
    } else {
      if (cell.pawn.hasBomb) {
        bg = openBombBg;
      } else {
        bg = openEmptyBg(bombsCountColors[cell.pawn.neighbourBombs]);
      }
    }

    Widget symbolFg(String symbol, [double fix = 1.0]) {
      return Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Text(
              symbol,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fix * 0.8 * constraints.maxHeight,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            );
          },
        ),
      );
    }

    late final Widget child;
    if (!cell.pawn.openend) {
      if (cell.pawn.flagged) {
        child = symbolFg('🚩', 0.85);
      } else {
        child = const SizedBox.expand();
      }
    } else {
      if (cell.pawn.hasBomb) {
        child = symbolFg('💣', 0.85);
      } else if (cell.pawn.neighbourBombs > 0) {
        child = symbolFg('${cell.pawn.neighbourBombs}');
      } else {
        child = const SizedBox.expand();
      }
    }
    return GradientRRBeeCellBg(
      bgGradient: bg,
      splashColor: Colors.teal,
      onPressed: onPressed,
      onLongPressed: onLongPressed,
      child: child,
    );
  }
}
