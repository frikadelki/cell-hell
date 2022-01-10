import 'package:flutter/material.dart';
import 'package:frock/frock.dart';
import 'package:puffy_playground/src/common/grid.dart';

import 'control_scheme.dart';
import 'game.dart';
import 'game_state.dart';
import 'grid_widgets.dart';
import 'presets.dart';
import 'settings_drawer.dart';

class SweepPage extends StatefulWidget {
  const SweepPage({Key? key}) : super(key: key);

  @override
  State<SweepPage> createState() => _SweepPageState();
}

class _SweepPageState extends State<SweepPage> with LifetimedState<SweepPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late final SweepGame _game;

  final _lastPresetProperty = ValueStream<SweepPreset>(defaultSweepPreset);

  final _controlSchemeProperty =
      ValueStream<ControlScheme>(ControlScheme.PrimaryOpens);

  @override
  void initLifetimedState(Lifetime lifetime) {
    _game = SweepGame(lifetime, _lastPresetProperty.value.gameSpec);
    lifetime.add(() {
      _lastPresetProperty.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppbar(),
      endDrawer: _buildSettingsDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildSettingsDrawer() {
    return SettingsDrawer(
      lastPreset: _lastPresetProperty,
      controlScheme: _controlSchemeProperty,
      onNewGame: (preset) {
        _lastPresetProperty.value = preset;
        _game.restartGame(preset.gameSpec);
      },
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
        onPressed: (x, y) => _controlSchemeProperty.value.executePrimary(
          open: () => empty.start(BeeVector(x, y)),
          flag: () {},
        ),
        onLongPressed: (x, y) => _controlSchemeProperty.value.executeSecondary(
          open: () => empty.start(BeeVector(x, y)),
          flag: () {},
        ),
      ),
      running: (running) => RunningSweepGridWidget(
        grid: running.grid,
        updateSignal: running.gridUpdateSignal,
        onCellPressed: (cell) => _controlSchemeProperty.value.executePrimary(
          open: () => running.openPawn(cell.point),
          flag: () => running.invertFlag(cell.point),
        ),
        onCellLongPressed: (cell) =>
            _controlSchemeProperty.value.executeSecondary(
          open: () => running.openPawn(cell.point),
          flag: () => running.invertFlag(cell.point),
        ),
      ),
      completedLoss: (loss) => CompletedSweepGridWidget(grid: loss.grid),
      completedWin: (win) => CompletedSweepGridWidget(grid: win.grid),
    ));
  }
}
