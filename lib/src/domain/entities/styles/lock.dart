import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:animax_player/src/domain/entities/styles/bar.dart';

class LockStyle {
  /// It is the style that will have all the icons and elements of the progress bar
  LockStyle({
    BarStyle? bar,
    Widget? lock,
    Widget? locked,
    Color? backgroundColor,
    this.paddingBeetwen = 12,
  })  : bar = bar ?? BarStyle.progress(),
        backgroundColor = backgroundColor ?? Colors.black.withOpacity(.4),
        lock = lock ??
            const Icon(Remix.lock_unlock_line, color: Colors.white, size: 20),
        locked = locked ??
            const Icon(Remix.lock_line, color: Colors.white, size: 20);

  /// It is the padding that will have the icons and the progressBar
  final double paddingBeetwen;

  /// It is the icon that appears when you want to enter full screen.
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Remix.fullscreen_outlined, color: Colors.white, size: 24);
  ///```
  final Widget lock;

  /// It is the icon that appears when you want to exit the full screen.
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Remix.fullscreen_exit_outlined, color: Colors.white, size: 24);
  ///```
  final Widget locked;

  /// It is the background color that the gradient and the PreviewFrame will have
  ///
  ///DEFAULT:
  ///```dart
  ///  Colors.black.withOpacity(0.28);
  ///```
  final Color backgroundColor;

  ///DEFAULT:
  ///```dart
  ///  BarStyle.progress();
  ///```
  final BarStyle bar;
}
