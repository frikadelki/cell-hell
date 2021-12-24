import 'package:flutter/material.dart';
import 'package:puffy_playground/src/common/cell_widget.dart';
import 'package:puffy_playground/src/common/grid_widget.dart';
import 'package:puffy_playground/src/f01_life/pawn.dart';

class LifeGridWidget extends StatelessWidget {
  final LifeGridRO grid;

  final Stream<void> updateSignal;

  final void Function(LifeCellRO cell) onCellPressed;

  const LifeGridWidget({
    Key? key,
    required this.grid,
    required this.updateSignal,
    required this.onCellPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BeeGridWidget<LifePawnRO>(
      grid: grid,
      updateSignal: updateSignal,
      cellBuilder: (context, cell) {
        return LifeCellWidget(
          cell: cell,
          onPressed: () => onCellPressed(cell),
        );
      },
    );
  }
}

/// '✺' : '♣';
/// '✘' : '♣';
class LifeCellWidget extends StatelessWidget {
  final LifeCellRO cell;

  final VoidCallback onPressed;

  const LifeCellWidget({
    Key? key,
    required this.cell,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const bg1 = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        Colors.blueGrey,
        Colors.grey,
      ],
    );
    const bg2 = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white,
        Colors.amber,
        Colors.orange,
      ],
    );
    return GradientRRBeeCellBg(
      bgGradient: cell.pawn.alive ? bg1 : bg2,
      splashColor: Colors.teal,
      onPressed: onPressed,
      child: const SizedBox.expand(),
    );
  }
}
