import 'package:flutter/material.dart';
import 'package:frock/frock.dart';

class ControlButton extends StatelessWidget {
  final IconData icon;

  final VoidCallback onPressed;

  const ControlButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    const padding = EdgeInsets.all(0.0);
    return OutlinedButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(padding),
        minimumSize: MaterialStateProperty.all(const Size(0, 0)),
      ),
      onPressed: onPressed,
      child: Icon(
        icon,
        size: size,
      ),
    );
  }
}

class RunButton extends StatelessWidget {
  final ValueStreamRO<bool> runningController;

  final VoidCallback onToggle;

  const RunButton({
    Key? key,
    required this.runningController,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: runningController,
      builder: (context, _) {
        return FloatingActionButton(
          onPressed: onToggle,
          child: runningController.value
              ? const Icon(Icons.pause)
              : const Icon(Icons.play_arrow),
        );
      },
    );
  }
}
