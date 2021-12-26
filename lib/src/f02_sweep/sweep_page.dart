import 'package:flutter/material.dart';
import 'package:frock/frock.dart';
import 'package:puffy_playground/src/common/buttons.dart';

import 'game.dart';
import 'game_state.dart';
import 'grid_widgets.dart';

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
      appBar: _buildAppbar(),
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
      title: StreamBuilder(
        stream: _game.gameStateStream,
        builder: (context, _) {
          return _game.gameStateStream.value.visit(GameStateVisitor(
            empty: () {
              return const Text('Sweeper');
            },
            running: () {
              return const Text('Running');
            },
            completedWin: (WonGameState win) {
              return const Text('Won');
            },
            completedLoss: (LostGameState loss) {
              return const Text('Lost');
            },
          ));
        },
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
        onCellPressed: _game.openPawn,
        onCellLongPressed: _game.invertFlag,
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
          onPressed: _game.restartGame,
        ),
        const SizedBox(width: 16.0),
        ControlButton(
          icon: Icons.remove_red_eye,
          onPressed: _game.forfeit,
        ),
      ],
    );
  }
}
