import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class Misc {
  Misc();

  static double lerpDouble(num a, num b, double t) {
    return ui.lerpDouble(a, b, t)!;
  }

  static double degreesToRadians(double degrees) {
    const double degrees2radians = math.pi / 180.0;
    return degrees * degrees2radians;
  }

  static void onLayoutRendered(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }

  static Future<void> delayed(
    int milliseconds,
    VoidCallback callback,
  ) async {
    await Future.delayed(
      Duration(milliseconds: milliseconds),
      () => callback(),
    );
  }

  static Timer timer(int milliseconds, VoidCallback callback) {
    return Timer(Duration(milliseconds: milliseconds), callback);
  }

  static Timer periodic(int milliseconds, VoidCallback callback) {
    return Timer.periodic(
      Duration(milliseconds: milliseconds),
      (_) => callback(),
    );
  }
}
