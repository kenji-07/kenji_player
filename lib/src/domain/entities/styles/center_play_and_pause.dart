import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
        play = play ??
            Icon(PhosphorIcons.play(PhosphorIconsStyle.fill),
                color: Colors.white, size: 35),
        pause = pause ??
            Icon(PhosphorIcons.pause(PhosphorIconsStyle.fill),
                color: Colors.white, size: 35),
        replay = replay ??
            Icon(PhosphorIcons.arrowsClockwise(),
                color: Colors.white, size: 30),
        rewind = rewind ??
            Icon(PhosphorIcons.rewind(PhosphorIconsStyle.fill),
                color: Colors.white, size: 30),
        forward = forward ??
            Icon(PhosphorIcons.fastForward(PhosphorIconsStyle.fill),
                color: Colors.white, size: 30);

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
