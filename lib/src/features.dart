import 'package:flutter/material.dart';
import 'package:cell_hell/src/f01_life/life_page.dart';
import 'package:cell_hell/src/f02_sweep/sweep_page.dart';

class FeatureItem {
  final String name;

  final WidgetBuilder pageBuilder;

  const FeatureItem({required this.name, required this.pageBuilder});
}

final featuresItems = [
  FeatureItem(
    name: 'Minesweeper',
    pageBuilder: (context) => const SweepPage(),
  ),
  FeatureItem(
    name: 'Conway\'s Life',
    pageBuilder: (context) => const LifePage(),
  ),
];
