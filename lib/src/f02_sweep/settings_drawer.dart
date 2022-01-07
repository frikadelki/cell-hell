import 'dart:math' as math;

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:frock/frock.dart';
import 'package:puffy_playground/src/common/discrete_slider.dart';
import 'package:puffy_playground/src/common/grid.dart';

import 'game_spec.dart';

class SettingsDrawer extends StatefulWidget {
  final void Function(GameSpec gameSpec) onNewGame;

  const SettingsDrawer({
    Key? key,
    required this.onNewGame,
  }) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsDrawer>
    with LifetimedState<SettingsDrawer> {
  final _gridSizeController = ValueStream<BeeVector>(
      BeeVector(sweepDefultGameSpec.width, sweepDefultGameSpec.height));

  final _gridBombsController = ValueStream<int>(sweepDefultGameSpec.bombs);

  @override
  void initLifetimedState(Lifetime lifetime) {
    lifetime.add(() {
      _gridSizeController.close();
      _gridBombsController.close();
    });
    _gridSizeController.observe(lifetime, (size) {
      _gridBombsController.value = sweepDefaultBombs(size.x, size.y);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              'Sweeper',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _NewGameCard(
            gridSizeController: _gridSizeController,
            bombsCountController: _gridBombsController,
            onNewGame: () {
              final size = _gridSizeController.value;
              final bombs = _gridBombsController.value;
              widget.onNewGame(GameSpec(size, bombs));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _NewGameCard extends StatelessWidget {
  final ValueStream<BeeVector> gridSizeController;

  final ValueStream<int> bombsCountController;

  final VoidCallback onNewGame;

  const _NewGameCard({
    Key? key,
    required this.gridSizeController,
    required this.bombsCountController,
    required this.onNewGame,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.all(0.0),
      shape: const RoundedRectangleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _GridSizeWidget(sizeController: gridSizeController),
            StreamBuilder(
              stream: StreamGroup.merge([
                gridSizeController,
                bombsCountController,
              ]),
              builder: (context, _) {
                final size = gridSizeController.value;
                return _GridBombsWidget(
                  maxBombs: sweepMaxBombs(size.x, size.y),
                  bombs: bombsCountController.value,
                  onChanged: (bombs) {
                    bombsCountController.value = bombs;
                  },
                );
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: onNewGame,
              child: const Text('New Game'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridSizeScales {
  static const _scales = [0, 8, 10, 16, 20, 24];

  static final sizes =
      _scales.map((scale) => BeeVector(scale, scale)).toList(growable: false);

  static const customSize = BeeVector(0, 0);
}

class _GridSizeWidget extends StatelessWidget {
  final ValueStream<BeeVector> sizeController;

  const _GridSizeWidget({Key? key, required this.sizeController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: sizeController,
      builder: (context, _) {
        return _build(context);
      },
    );
  }

  Widget _build(BuildContext context) {
    final sizeValue = sizeController.value;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Size'),
            Expanded(
              child: DiscreteSlider<BeeVector>(
                items: _GridSizeScales.sizes,
                value: sizeValue,
                onChanged: (value) {
                  sizeController.value = value;
                },
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 44.0),
              alignment: Alignment.center,
              child: () {
                if (_GridSizeScales.customSize == sizeValue) {
                  return const Text('CUSTOM');
                } else {
                  return Text('${sizeValue.x}x${sizeValue.y}');
                }
              }(),
            ),
          ],
        ),
      ],
    );
  }
}

class _GridBombsWidget extends StatelessWidget {
  final int maxBombs;

  final int bombs;

  final ValueChanged<int> onChanged;

  const _GridBombsWidget({
    Key? key,
    required this.maxBombs,
    required this.bombs,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Bombs'),
        Expanded(
          child: Slider(
            min: 1.0,
            max: maxBombs.toDouble(),
            divisions: math.max(maxBombs - 1, 1),
            value: bombs.toDouble(),
            onChanged: (value) {
              onChanged(value.toInt());
            },
          ),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 44.0),
          alignment: Alignment.center,
          child: Text('$bombs'),
        ),
      ],
    );
  }
}
