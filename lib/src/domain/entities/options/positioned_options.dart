import 'package:flutter/material.dart';

class PositionedOptions {
  final double? width;
  final double? height;
  final double? right;
  final BorderRadius? borderRadius;
  final bool? blur;

  const PositionedOptions({
    this.width = 200,
    this.height = 200,
    this.right = 20,
    this.borderRadius,
    this.blur = true,
  });

  BorderRadius get effectiveBorderRadius =>
      borderRadius ?? BorderRadius.circular(20);
}
