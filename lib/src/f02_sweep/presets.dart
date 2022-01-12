import 'package:cell_hell/src/common/grid.dart';

import 'game_spec.dart';

class SweepPreset {
  final String name;

  final BeeVector size;

  final int bombs;

  const SweepPreset(this.name, this.size, this.bombs);

  GameSpec get gameSpec => GameSpec(size, bombs);
}

const customSweepPreset = SweepPreset('Custom', BeeVector.zero, 0);
const defaultSweepPreset = SweepPreset('Novice', BeeVector(8, 16), 12);

const sweepPresets = [
  // TODO: customSweepPreset,
  defaultSweepPreset,
  SweepPreset('Sweeper', BeeVector(10, 18), 24),
  SweepPreset('Expert', BeeVector(12, 20), 44),
  SweepPreset('H-t-H', BeeVector(5, 10), 5 * 10 - 16),
];

extension SweepPresetCustom on SweepPreset {
  bool get custom => customSweepPreset == this || !sweepPresets.contains(this);
}
