import 'package:flutter/material.dart';

class GradientRRBeeCellBg extends StatelessWidget {
  final Gradient bgGradient;

  final Color outlineColor;

  final Color? splashColor;

  final VoidCallback? onPressed;

  final VoidCallback? onLongPressed;

  final Widget child;

  const GradientRRBeeCellBg({
    Key? key,
    required this.bgGradient,
    this.outlineColor = Colors.black,
    this.splashColor,
    this.onPressed,
    this.onLongPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(1.0),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          border: Border.all(color: outlineColor),
          gradient: bgGradient,
        ),
        child: Material(
          clipBehavior: Clip.hardEdge,
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
          type: MaterialType.transparency,
          child: InkResponse(
            highlightColor: splashColor?.withOpacity(0.25),
            splashColor: splashColor,
            onTap: onPressed,
            onDoubleTap: onLongPressed,
            onLongPress: onLongPressed,
            child: child,
          ),
        ),
      ),
    );
  }
}
