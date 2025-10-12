import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    this.child,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  final Widget? child;
  final Alignment begin;
  final Alignment end;

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      Colors.transparent,
      const Color(0x80000000),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(end: end, begin: begin, colors: colors),
      ),
      child: child,
    );
  }
}
