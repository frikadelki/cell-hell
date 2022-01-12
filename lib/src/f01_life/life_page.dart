import 'package:flutter/material.dart';
import 'package:frock/frock.dart';
import 'package:puffy_playground/src/common/buttons.dart';
import 'package:puffy_playground/src/common/features_navigation.dart';
import 'package:puffy_playground/src/f01_life/grid_widgets.dart';
import 'package:puffy_playground/src/f01_life/life_game.dart';

class LifePage extends StatefulWidget {
  const LifePage({Key? key}) : super(key: key);

  @override
  State<LifePage> createState() => _LifePageState();
}

class _LifePageState extends State<LifePage> with LifetimedState<LifePage> {
  late final LifeGame _game;

  @override
  void initLifetimedState(Lifetime lifetime) {
    _game = LifeGame(lifetime, 16, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conway\'s Life'),
      ),
      drawer: const FeaturesNavigationDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildBody(),
        ),
      ),
      floatingActionButton: RunButton(
        runningController: _game.runningStream,
        onToggle: _game.togglePlay,
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
      child: LifeGridWidget(
        grid: _game.grid,
        updateSignal: _game.gridUpdatedSignal,
        onCellPressed: (cell) => _game.invertPawn(cell.x, cell.y),
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
          icon: Icons.casino,
          onPressed: _game.randomizeGrid,
        ),
        const SizedBox(width: 16.0),
        ControlButton(
          icon: Icons.cancel,
          onPressed: _game.clearGrid,
        ),
      ],
    );
  }
}
