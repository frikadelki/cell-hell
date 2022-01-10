import 'package:flutter/material.dart';
import 'package:puffy_playground/src/common/cell_widget.dart';
import 'package:puffy_playground/src/common/grid_widget.dart';

import 'game_pawn.dart';

class EmptySweepGridWidget extends StatelessWidget {
  final int width;

  final int height;

  final void Function(int x, int y) onPressed;

  final void Function(int x, int y) onLongPressed;

  const EmptySweepGridWidget({
    Key? key,
    required this.width,
    required this.height,
    required this.onPressed,
    required this.onLongPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OrientationAspectGridWidget(
      width: width,
      height: height,
      cellBuilder: (context, x, y) {
        return ClosedCellBg(
          onPressed: () => onPressed(x, y),
          onLongPressed: () => onLongPressed(x, y),
        );
      },
    );
  }
}

class CompletedSweepGridWidget extends StatelessWidget {
  final SweepGridRO grid;

  const CompletedSweepGridWidget({
    Key? key,
    required this.grid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeeGridWidget<SweepPawnRO>(
      grid: grid,
      cellBuilder: (context, cell) {
        return SweepCellWidget(cell: cell);
      },
    );
  }
}

class RunningSweepGridWidget extends StatelessWidget {
  final SweepGridRO grid;

  final Stream<void> updateSignal;

  final void Function(SweepCellRO cell) onCellPressed;

  final void Function(SweepCellRO cell) onCellLongPressed;

  const RunningSweepGridWidget({
    Key? key,
    required this.grid,
    required this.updateSignal,
    required this.onCellPressed,
    required this.onCellLongPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: updateSignal,
      builder: (context, _) {
        return BeeGridWidget<SweepPawnRO>(
          grid: grid,
          cellBuilder: (context, cell) {
            return SweepCellWidget(
              cell: cell,
              onPressed: () => onCellPressed(cell),
              onLongPressed: () => onCellLongPressed(cell),
            );
          },
        );
      },
    );
  }
}

/// '✺' : '♣';
/// '✘' : '♣';
class SweepCellWidget extends StatelessWidget {
  final SweepCellRO cell;

  final VoidCallback? onPressed;

  final VoidCallback? onLongPressed;

  const SweepCellWidget({
    Key? key,
    required this.cell,
    this.onPressed,
    this.onLongPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pawn = cell.pawn;
    if (pawn.openend) {
      if (pawn.hasBomb) {
        return const OpenBombCell();
      } else {
        return OpenEmptyCell(neighbourBombs: pawn.neighbourBombs);
      }
    } else {
      return ClosedCell(
        flagged: pawn.flagged,
        onPressed: onPressed,
        onLongPressed: onLongPressed,
      );
    }
  }
}

class SymbolFg extends StatelessWidget {
  final String symbol;

  final double fix;

  const SymbolFg({
    Key? key,
    required this.symbol,
    this.fix = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

class OpenBombCell extends StatelessWidget {
  const OpenBombCell({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GradientRRBeeCellBg(
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Colors.brown.shade300,
          Colors.brown.shade200,
        ],
      ),
      child: const SymbolFg(symbol: '💣'),
    );
  }
}

class OpenEmptyCell extends StatelessWidget {
  static final bombsCountColors = [
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

  final int neighbourBombs;

  const OpenEmptyCell({
    Key? key,
    required this.neighbourBombs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final baseBgColor = bombsCountColors[neighbourBombs];
    return GradientRRBeeCellBg(
      bgGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          baseBgColor,
          Colors.white,
        ],
      ),
      child: neighbourBombs > 0
          ? SymbolFg(symbol: '$neighbourBombs')
          : const SizedBox.expand(),
    );
  }
}

class ClosedCell extends StatelessWidget {
  final bool flagged;

  final VoidCallback? onPressed;

  final VoidCallback? onLongPressed;

  const ClosedCell({
    Key? key,
    required this.flagged,
    required this.onPressed,
    required this.onLongPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClosedCellBg(
      onPressed: onPressed,
      onLongPressed: onLongPressed,
      child: flagged ? const SymbolFg(symbol: '🚩', fix: 0.85) : null,
    );
  }
}

class ClosedCellBg extends StatelessWidget {
  final VoidCallback? onPressed;

  final VoidCallback? onLongPressed;

  final Widget? child;

  const ClosedCellBg({
    Key? key,
    this.onPressed,
    this.onLongPressed,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const bg = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        Colors.blueGrey,
        Colors.grey,
      ],
    );
    return GradientRRBeeCellBg(
      bgGradient: bg,
      splashColor: Colors.teal,
      onPressed: onPressed,
      onLongPressed: onLongPressed,
      child: child != null ? child! : const SizedBox.expand(),
    );
  }
}
