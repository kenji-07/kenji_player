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

  static const List<Color> _gradientColors = [
    Colors.transparent,
    Color(0x80000000),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: _gradientColors,
        ),
      ),
      child: child,
    );
  }
}
