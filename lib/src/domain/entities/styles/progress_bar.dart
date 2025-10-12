import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:animax_player/src/domain/entities/styles/bar.dart';

class ProgressBarStyle {
  /// It is the style that will have all the icons and elements of the progress bar
  ProgressBarStyle({
    BarStyle? bar,
    Widget? fullScreen,
    Widget? fullScreenExit,
    Color? backgroundColor,
    this.paddingBeetwen = 12,
  })  : bar = bar ?? BarStyle.progress(),
        backgroundColor = backgroundColor ?? Colors.black.withOpacity(.8),
        fullScreen = fullScreen ??
            const Icon(Remix.fullscreen_line, color: Colors.white, size: 24),
        fullScreenExit = fullScreenExit ??
            const Icon(
              Remix.fullscreen_exit_line,
              color: Colors.white,
              size: 24,
            );

  /// It is the padding that will have the icons and the progressBar
  final double paddingBeetwen;

  /// It is the icon that appears when you want to enter full screen.
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Remix.fullscreen_outlined, color: Colors.white, size: 24);
  ///```
  final Widget fullScreen;

  /// It is the icon that appears when you want to exit the full screen.
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Remix.fullscreen_exit_outlined, color: Colors.white, size: 24);
  ///```
  final Widget fullScreenExit;

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
