import 'package:flutter/material.dart';

import 'package:kenji_player/src/ui/widgets/transition.dart';
import 'package:kenji_player/src/data/repositories/video.dart';

class CustomOpacityTransition extends StatelessWidget {
  const CustomOpacityTransition({
    super.key,
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoMetadata(context).style;

    return OpacityTransition(
      curve: Curves.ease,
      duration: style.transitions,
      visible: visible,
      child: child,
    );
  }
}

class CustomSwipeTransition extends StatelessWidget {
  const CustomSwipeTransition({
    super.key,
    required this.visible,
    required this.child,
    this.axisAlignment = -1.0,
    this.axis = Axis.vertical,
  });

  final bool visible;
  final Widget child;
  final double axisAlignment;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoMetadata(context).style;

    return SwipeTransition(
      curve: Curves.ease,
      axis: axis,
      duration: style.transitions,
      axisAlignment: axisAlignment,
      visible: visible,
      child: child,
    );
  }
}
