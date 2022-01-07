import 'package:flutter/material.dart';
import 'package:frock/frock.dart';
import 'package:puffy_playground/src/common/discrete_slider.dart';

import 'game_spec.dart';
import 'presets.dart';

class SettingsDrawer extends StatefulWidget {
  final ValueStreamRO<SweepPreset> lastPreset;

  final void Function(SweepPreset preset) onNewGame;

  const SettingsDrawer({
    Key? key,
    required this.lastPreset,
    required this.onNewGame,
  }) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<SettingsDrawer>
    with LifetimedState<SettingsDrawer> {
  final _presetController = ValueStream<SweepPreset>(defaultSweepPreset);

  @override
  void initLifetimedState(Lifetime lifetime) {
    _presetController.value = widget.lastPreset.value;
    lifetime.add(() {
      _presetController.close();
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
            presetController: _presetController,
            onNewGame: () {
              widget.onNewGame(_presetController.value);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _NewGameCard extends StatelessWidget {
  final ValueStream<SweepPreset> presetController;

  final VoidCallback onNewGame;

  const _NewGameCard({
    Key? key,
    required this.presetController,
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Text(
                'New Game',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            _NewGameOptionsWidget(sizeController: presetController),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onNewGame,
                child: const Text('START'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewGameOptionsWidget extends StatelessWidget {
  final ValueStream<SweepPreset> sizeController;

  final bool showInfo;

  const _NewGameOptionsWidget({
    Key? key,
    required this.sizeController,
    this.showInfo = false,
  }) : super(key: key);

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
    final preset = sizeController.value;
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
            Expanded(
              child: DiscreteSlider<SweepPreset>(
                items: sweepPresets,
                value: preset,
                onChanged: (value) {
                  sizeController.value = value;
                },
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 64.0),
              alignment: Alignment.center,
              child: Text(
                preset.name,
                //style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
        if (showInfo)
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!preset.custom) ...[
                Expanded(
                  flex: 2,
                  child: Text(
                    '${preset.size.x}x${preset.size.y}',
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${preset.bombs}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ] else ...[
                // TODO
                const Text(
                  'CUSTOM',
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
      ],
    );
  }
}
