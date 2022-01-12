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
    _game = LifeGame(lifetime, 32, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
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

  PreferredSizeWidget _buildAppbar() {
    return AppBar(
      title: const Text('Conway\'s Life'),
      actions: [
        IconButton(
          icon: const Icon(Icons.casino),
          onPressed: _game.randomizeGrid,
        ),
        IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: _game.clearGrid,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Center(
      child: _buildGrid(),
    );
  }

  Widget _buildGrid() {
    return LifeGridWidget(
      grid: _game.grid,
      updateSignal: _game.gridUpdatedSignal,
      onCellPressed: (cell) => _game.invertPawn(cell.x, cell.y),
    );
  }
}
