import 'package:flutter/material.dart';

class DiscreteSlider<T> extends StatelessWidget {
  final List<T> items;

  final T value;

  final ValueChanged<T> onChanged;

  const DiscreteSlider({
    Key? key,
    required this.items,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var currentIndex = items.indexOf(value);
    if (currentIndex < 0) {
      currentIndex = 0;
    }
    return Slider(
      min: 0.0,
      max: (items.length - 1).toDouble(),
      divisions: items.length - 1,
      value: currentIndex.toDouble(),
      onChanged: (value) => onChanged(items[value.toInt()]),
    );
  }
}
