import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class PlayAndPauseWidgetStyle {
  /// With this argument you will change the play and pause icons, also the style
  /// of the circle that appears behind. Note: The play and pause icons are
  /// the same ones that appear in the progress bar
  PlayAndPauseWidgetStyle({
    Widget? play,
    Widget? pause,
    Widget? replay,
    Color? background,
    this.circleBorder,
    this.circleRadius = 40,
  })  : background =
            background ?? const Color(0xFF295acc).withValues(alpha: 0.8),
        play = play ?? const Icon(Remix.play_large_fill, color: Colors.white),
        pause =
            pause ?? const Icon(Remix.pause_large_fill, color: Colors.white),
        replay = replay ?? const Icon(Remix.memories_line, color: Colors.white);

  /// It is the icon that will have the play of the progress bar and also
  /// the one that appears in the middle of the screen
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Remix.play_arrow, color: Colors.white);
  ///```
  final Widget play;

  /// It is the icon that will have the play of the progress bar and also
  /// the one that appears in the middle of the screen
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Remix.play_arrow, color: Colors.white);
  ///```
  final Widget replay;

  /// It is the icon that will have the pause of the progress bar and also
  /// the one that appears in the middle of the screen
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Remix.pause, color: Colors.white);
  ///```
  final Widget pause;

  /// It is the background color that the play and pause icons will have
  ///
  ///DEFAULT:
  ///```dart
  ///  Color(0xFF295acc).withValues(alpha: 0.8);
  ///```
  final Color background;

  /// Is the size of the container
  final double circleRadius;

  /// It is the style of the border that the container will have
  final BoxBorder? circleBorder;

  Widget _base(Widget child, Color background) {
    return SizedBox(
      width: circleRadius,
      height: circleRadius,
      // decoration: BoxDecoration(
      //   shape: BoxShape.circle,
      //   color: background,
      //   border: circleBorder,
      // ),
      child: child,
    );
  }

  Widget get playWidget => _base(play, background);
  Widget get pauseWidget => _base(pause, background);
  Widget get replayWidget => _base(replay, background);
}
