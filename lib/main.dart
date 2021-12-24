import 'package:flutter/material.dart';
import 'package:puffy_playground/src/f01_life/life_page.dart';
import 'package:puffy_playground/src/f02_sweep/sweep_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cell Hell',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const LifePage(),
      home: const SweepPage(),
    );
  }
}
