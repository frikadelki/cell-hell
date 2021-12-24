import 'package:flutter/material.dart';
import 'package:puffy_playground/src/common/cell_widget.dart';
import 'package:puffy_playground/src/common/grid_widget.dart';

import 'pawn.dart';

class SweepGridWidget extends StatelessWidget {
  final SweepGridRO grid;

  final Stream<void> updateSignal;

  final void Function(SweepCellRO cell) onCellPressed;

  const SweepGridWidget({
    Key? key,
    required this.grid,
    required this.updateSignal,
    required this.onCellPressed,
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

  const SweepCellWidget({
    Key? key,
    required this.cell,
    required this.onPressed,
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

    const openBombBg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        Colors.brown,
        Colors.grey,
      ],
    );

    late final Gradient bg;
    if (!cell.pawn.openend) {
      bg = closedBg;
    } else {
      if (cell.pawn.hasBomb) {
        bg = openBombBg;
      } else if (!cell.pawn.hasNeighbourBombs) {
        bg = openEmptyBg(Colors.blue.shade100);
      } else if (cell.pawn.neighbourBombs == 1) {
        bg = openEmptyBg(Colors.green.shade100);
      } else if (cell.pawn.neighbourBombs == 2) {
        bg = openEmptyBg(Colors.green.shade300);
      } else if (cell.pawn.neighbourBombs == 3) {
        bg = openEmptyBg(Colors.yellow.shade400);
      } else if (cell.pawn.neighbourBombs == 4) {
        bg = openEmptyBg(Colors.yellow.shade700);
      } else if (cell.pawn.neighbourBombs == 5) {
        bg = openEmptyBg(Colors.orange.shade500);
      } else if (cell.pawn.neighbourBombs == 6) {
        bg = openEmptyBg(Colors.orange.shade800);
      } else if (cell.pawn.neighbourBombs == 7) {
        bg = openEmptyBg(Colors.red.shade500);
      } else {
        bg = openEmptyBg(Colors.red.shade800);
      }
    }

    late final Widget child;
    if (!cell.pawn.openend) {
      child = const SizedBox.expand();
    } else {
      if (cell.pawn.hasBomb) {
        child = const Text('💣');
      } else if (cell.pawn.neighbourBombs > 0) {
        child = Center(
          child: Text(
            '${cell.pawn.neighbourBombs}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        child = const SizedBox.expand();
      }
    }
    return GradientRRBeeCellBg(
      bgGradient: bg,
      splashColor: Colors.teal,
      onPressed: onPressed,
      child: child,
    );
  }
}
