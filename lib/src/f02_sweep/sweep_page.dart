import 'package:flutter/material.dart';
import 'package:frock/frock.dart';
import 'package:puffy_playground/src/common/grid.dart';
import 'package:puffy_playground/src/f02_sweep/settings_drawer.dart';

import 'game.dart';
import 'game_state.dart';
import 'grid_widgets.dart';

class SweepPage extends StatefulWidget {
  const SweepPage({Key? key}) : super(key: key);

  @override
  State<SweepPage> createState() => _SweepPageState();
}

class _SweepPageState extends State<SweepPage> with LifetimedState<SweepPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late final SweepGame _game;

  @override
  void initLifetimedState(Lifetime lifetime) {
    _game = SweepGame(lifetime, 16, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppbar(),
      endDrawer: SettingsDrawer(
        onNewGame: _game.restartGame,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildBody(),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppbar() {
    return AppBar(
      title: _buildAppbarTitle(),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            _game.restartGame();
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            _scaffoldKey.currentState!.openEndDrawer();
          },
        ),
      ],
    );
  }

  Widget _buildAppbarTitle() {
    return StreamBuilder(
      stream: _game.gameStateStream,
      builder: (context, _) {
        return _game.gameStateStream.value.visit(GameStateVisitor(
          empty: (empty) {
            return const Text('Sweeper');
          },
          running: (running) {
            return StreamBuilder(
              stream: running.remainingFlagsProperty,
              builder: (context, _) {
                return Text(
                  'Running\n'
                  '${running.remainingFlagsProperty.value}/${running.spec.bombs}',
                  textAlign: TextAlign.center,
                );
              },
            );
          },
          completedWin: (win) {
            return const Text('Won');
          },
          completedLoss: (loss) {
            return const Text('Lost');
          },
        ));
      },
    );
  }

  Widget _buildBody() {
    return Center(
      child: StreamBuilder(
        stream: _game.gameStateStream,
        builder: (context, _) => _buildGameGrid(_game.gameStateStream.value),
      ),
    );
  }

  Widget _buildGameGrid(GameState state) {
    return state.visit(GameStateVisitor(
      empty: (empty) => EmptySweepGridWidget(
        width: empty.spec.width,
        height: empty.spec.height,
        onPressed: (x, y) => empty.start(BeeVector(x, y)),
      ),
      running: (running) => RunningSweepGridWidget(
        grid: running.grid,
        updateSignal: running.gridUpdateSignal,
        onCellPressed: (cell) => running.openPawn(cell.point),
        onCellLongPressed: (cell) => running.invertFlag(cell.point),
      ),
      completedLoss: (loss) => CompletedSweepGridWidget(grid: loss.grid),
      completedWin: (win) => CompletedSweepGridWidget(grid: win.grid),
    ));
  }
}
