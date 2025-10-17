import 'package:flutter/material.dart';

import 'package:animax_player/src/domain/entities/styles/center_play_and_pause.dart';

import 'package:animax_player/src/domain/entities/styles/lock.dart';
import 'package:animax_player/src/domain/entities/styles/progress_bar.dart';
import 'package:animax_player/src/domain/entities/styles/subtitle.dart';
import 'package:animax_player/src/domain/entities/styles/fullscreen_subtitle.dart';

export 'package:animax_player/src/domain/entities/styles/bar.dart';
export 'package:animax_player/src/domain/entities/styles/center_play_and_pause.dart';
export 'package:animax_player/src/domain/entities/styles/progress_bar.dart';
export 'package:animax_player/src/domain/entities/styles/subtitle.dart';
export 'package:animax_player/src/domain/entities/styles/lock.dart';

class AnimaxPlayerStyle {
  /// It is the main class of AnimaxPlayer styles, in this class you can almost
  /// all styles and elements of the AnimaxPlayer
  AnimaxPlayerStyle({
    ProgressBarStyle? progressBarStyle,
    LockStyle? lock,
    CenterPlayAndPauseWidgetStyle? centerPlayAndPauseStyle,
    SubtitleStyle? subtitleStyle,
    FullscreenSubtitleStyle? fullscreenSubtitleStyle,
    Widget? loading,
    Widget? buffering,
    TextStyle? textStyle,
    this.episode,
    this.thumbnail,
    this.header,
    this.transitions = const Duration(milliseconds: 400),
    this.skipAdBuilder,
    this.skipAdAlignment = Alignment.bottomRight,
  })  : loading = loading ??
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        buffering = buffering ??
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        subtitleStyle = subtitleStyle ?? SubtitleStyle(),
        fullscreenSubtitleStyle =
            fullscreenSubtitleStyle ?? FullscreenSubtitleStyle(),
        progressBarStyle = progressBarStyle ?? ProgressBarStyle(),
        lock = lock ?? LockStyle(),
        centerPlayAndPauseStyle =
            centerPlayAndPauseStyle ?? CenterPlayAndPauseWidgetStyle(),
        textStyle = textStyle ??
            const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            );

  /// These are the styles of the settings sales, here you will change the icons and
  /// the language of the texts
  final Widget? episode;

  /// It is the style that will have all the icons and elements of the progress bar
  final ProgressBarStyle progressBarStyle;

  final LockStyle lock;

  final SubtitleStyle subtitleStyle;

  final FullscreenSubtitleStyle fullscreenSubtitleStyle;

  /// With this argument you will change the play and pause icons, also the style
  /// of the circle that appears behind. Note: The play and pause icons are
  /// the same ones that appear in the progress bar

  final CenterPlayAndPauseWidgetStyle centerPlayAndPauseStyle;

  /// It is a thumbnail that appears when the video is loaded for the first time, once
  /// given play or pressing on it will disappear.
  final Widget? thumbnail;

  /// It is the widget header shows on the top when you tap the video PLAYER and it shows the progress bar
  final Widget? header;

  /// It is the NotNull-Widget that appears when the video is loading.
  ///
  ///DEFAULT:
  ///```dart
  ///  Center(child: CircularProgressIndicator(strokeWidth: 1.6));
  ///```
  final Widget loading;

  /// It is the NotNull-Widget that appears when the video keeps loading the content
  ///
  ///DEFAULT:
  ///```dart
  ///  Center(child: CircularProgressIndicator(
  ///     strokeWidth: 1.6,
  ///     valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
  ///  );
  ///```
  final Widget buffering;

  /// It is a quantity in milliseconds. It is the time it takes to take place
  /// all transitions of the AnimaxPlayer ui,
  final Duration transitions;

  /// It is the design of the text that will be used in all the texts of the VideoViwer
  ///
  ///DEFAULT:
  ///```dart
  ///  TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
  ///```
  final TextStyle textStyle;

  final Widget Function(Duration)? skipAdBuilder;

  final Alignment skipAdAlignment;

  AnimaxPlayerStyle copyWith({
    Widget? episode,
    ProgressBarStyle? progressBarStyle,
    LockStyle? lock,
    SubtitleStyle? subtitleStyle,
    FullscreenSubtitleStyle? fullscreenSubtitleStyle,
    CenterPlayAndPauseWidgetStyle? centerPlayAndPauseStyle,
    Widget? thumbnail,
    Widget? header,
    Widget? loading,
    Widget? buffering,
    Duration? transitions,
    TextStyle? textStyle,
    Widget Function(Duration)? skipAdBuilder,
    Alignment? skipAdAlignment,
  }) {
    return AnimaxPlayerStyle(
      episode: episode ?? this.episode,
      progressBarStyle: progressBarStyle ?? this.progressBarStyle,
      lock: lock ?? this.lock,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      fullscreenSubtitleStyle:
          fullscreenSubtitleStyle ?? this.fullscreenSubtitleStyle,
      centerPlayAndPauseStyle:
          centerPlayAndPauseStyle ?? this.centerPlayAndPauseStyle,
      thumbnail: thumbnail ?? this.thumbnail,
      header: header ?? this.header,
      loading: loading ?? this.loading,
      buffering: buffering ?? this.buffering,
      transitions: transitions ?? this.transitions,
      textStyle: textStyle ?? this.textStyle,
      skipAdBuilder: skipAdBuilder ?? this.skipAdBuilder,
      skipAdAlignment: skipAdAlignment ?? this.skipAdAlignment,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AnimaxPlayerStyle &&
        other.episode == episode &&
        other.progressBarStyle == progressBarStyle &&
        other.lock == lock &&
        other.subtitleStyle == subtitleStyle &&
        other.fullscreenSubtitleStyle == fullscreenSubtitleStyle &&
        other.centerPlayAndPauseStyle == centerPlayAndPauseStyle &&
        other.thumbnail == thumbnail &&
        other.header == header &&
        other.loading == loading &&
        other.buffering == buffering &&
        other.transitions == transitions &&
        other.textStyle == textStyle &&
        other.skipAdBuilder == skipAdBuilder &&
        other.skipAdAlignment == skipAdAlignment;
  }

  @override
  int get hashCode {
    return episode.hashCode ^
        progressBarStyle.hashCode ^
        lock.hashCode ^
        subtitleStyle.hashCode ^
        fullscreenSubtitleStyle.hashCode ^
        centerPlayAndPauseStyle.hashCode ^
        thumbnail.hashCode ^
        header.hashCode ^
        loading.hashCode ^
        buffering.hashCode ^
        transitions.hashCode ^
        textStyle.hashCode ^
        skipAdBuilder.hashCode ^
        skipAdAlignment.hashCode;
  }
}
