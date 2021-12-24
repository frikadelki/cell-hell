import 'package:flutter/material.dart';
import 'package:frock/frock.dart';
import 'package:puffy_playground/src/common/buttons.dart';

import 'grid_widgets.dart';
import 'sweep_game.dart';

class SweepPage extends StatefulWidget {
  const SweepPage({Key? key}) : super(key: key);

  @override
  State<SweepPage> createState() => _SweepPageState();
}

class _SweepPageState extends State<SweepPage> with LifetimedState<SweepPage> {
  late final SweepGame _game;

  @override
  void initLifetimedState(Lifetime lifetime) {
    _game = SweepGame(lifetime, 16, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sweeper'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return OrientationBuilder(
      builder: (context, orientation) {
        switch (orientation) {
          case Orientation.portrait:
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  child: IntrinsicHeight(
                    child: Center(
                      child: _buildGrid(),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                _buildMenu(),
              ],
            );

          case Orientation.landscape:
            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Flexible(
                  child: IntrinsicWidth(
                    child: Center(
                      child: _buildGrid(),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                _buildMenu(),
              ],
            );
        }
      },
    );
  }

  Widget _buildGrid() {
    return AspectRatio(
      aspectRatio: 1.0,
      child: SweepGridWidget(
        grid: _game.grid,
        updateSignal: _game.gridUpdatedSignal,
        onCellPressed: (cell) => _game.openPawn(cell.x, cell.y),
      ),
    );
  }

  Widget _buildMenu() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ControlButton(
          icon: Icons.cancel,
          onPressed: _game.clearGrid,
        ),
        const SizedBox(width: 16.0),
        ControlButton(
          icon: Icons.remove_red_eye,
          onPressed: _game.revealGrid,
        ),
      ],
    );
  }
}
