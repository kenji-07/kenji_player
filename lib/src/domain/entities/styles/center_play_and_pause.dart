import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CenterPlayAndPauseWidgetStyle {
  /// With this argument you will change the play and pause icons, also the style
  /// of the circle that appears behind. Note: The play and pause icons are
  /// the same ones that appear in the progress bar
  CenterPlayAndPauseWidgetStyle({
    Widget? play,
    Widget? pause,
    Widget? replay,
    Widget? rewind,
    Widget? forward,
    Color? background,
    this.circleBorder,
    this.circleRadius = 60,
  })  : background = background ?? Colors.black.withValues(alpha: 0.3),
        play =
            play ?? const Icon(Icons.play_arrow, color: Colors.white, size: 45),
        pause = pause ?? const Icon(Icons.pause, color: Colors.white, size: 45),
        replay = replay ??
            const Icon(Iconsax.refresh_copy, color: Colors.white, size: 30),
        rewind = rewind ??
            const Icon(Icons.fast_rewind, color: Colors.white, size: 30),
        forward = forward ??
            const Icon(Icons.fast_forward, color: Colors.white, size: 30);

  final Widget rewind;
  final Widget forward;

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
    return Container(
      width: circleRadius,
      height: circleRadius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        border: circleBorder,
      ),
      child: child,
    );
  }

  Widget get playWidget => _base(play, background);
  Widget get pauseWidget => _base(pause, background);
  Widget get replayWidget => _base(replay, background);
  Widget get rewindWidget => _base(rewind, background);
  Widget get forwardWidget => _base(forward, background);
}
