import 'package:kenji_player/src/domain/entities/styles/kenji_player.dart';
import 'package:flutter/material.dart';

class KenjiPlayerMetadata {
  KenjiPlayerMetadata({
    required this.defaultAspectRatio,
    required this.rewindAmount,
    required this.forwardAmount,
    required this.style,
    required this.enableFullscreenScale,
    required this.volume,
    required this.brightness,
    required this.lock,
    required this.caption,
    required this.aspect,
    required this.opStart,
    required this.opEnd,
    required this.edStart,
    required this.edEnd,
  });

  /// OP Start, OP End & END Start, END End
  final Duration opStart;
  final Duration opEnd;
  final Duration edStart;
  final Duration edEnd;

  /// It is the Aspect Ratio that the widget.style.loading will take when the video
  /// is not initialized yet
  final double defaultAspectRatio;

  /// It is the amount of seconds that the video will be delayed when double tapping.
  final int rewindAmount;

  /// It is the amount of seconds that the video will be advanced when double tapping.
  final int forwardAmount;

  ///If it is `true`, when entering the fullscreen it will be fixed
  ///in landscape mode and it will not be possible to rotate it in portrait.
  ///If it is `false`, you can rotate the entire screen in any position.

  ///It's the custom language can you set to the KenjiPlayer.
  ///
  ///**EXAMPLE:** SETTING THE SPANISH LANGUAGE TO THE KenjiPlayer
  ///```dart
  /// //WAY 1
  /// language: KenjiPlayerLanguage.es
  /// //WAY 2
  /// language: KenjiPlayerLanguage(quality: "Calidad", speed: "Velocidad", ...)
  /// //WAY 3
  /// language: KenjiPlayerLanguage.fromString("es")
  /// ```

  /// It is an argument where you can change the design of almost the entire KenjiPlayer
  final KenjiPlayerStyle style;

  final bool enableFullscreenScale;

  final bool volume;

  final bool brightness;

  final bool lock;

  final bool caption;

  final BoxFit aspect;
}
