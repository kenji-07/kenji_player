import 'package:flutter/material.dart';

class FullscreenSubtitleStyle {
  final TextStyle fullStyle;
  final TextAlign textAlign;
  final Alignment alignment;
  final EdgeInsetsGeometry padding;

  FullscreenSubtitleStyle({
    TextStyle? style,
    this.alignment = Alignment.bottomCenter,
    this.textAlign = TextAlign.center,
    this.padding = const EdgeInsets.all(0.0),
  }) : fullStyle = style ??
            const TextStyle(
              color: Colors.white,
              fontSize: 23,
              backgroundColor: Colors.black,
              height: 1.2,
            );
}
