import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:animax_player/src/ui/widgets/transition.dart';
import 'package:animax_player/src/data/repositories/video.dart';
import 'package:animax_player/src/domain/entities/styles/animax_player.dart';
import 'package:animax_player/src/ui/widgets/transitions.dart';

class VideoProgressBar extends StatefulWidget {
  const VideoProgressBar({super.key});

  @override
  VideoProgressBarState createState() => VideoProgressBarState();
}

class VideoProgressBarState extends State<VideoProgressBar> {
  final ValueNotifier<Duration> _progressBarDraggingBuffer =
      ValueNotifier<Duration>(Duration.zero);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => ValueNotifier<int>(1000)),
        ListenableProvider.value(value: _progressBarDraggingBuffer),
      ],
      child: LayoutBuilder(
        builder: (_, constraints) {
          final query = VideoQuery();
          final controller = query.video(context, listen: true);
          final videoStyle = query.videoStyle(context);
          final style = videoStyle.progressBarStyle;
          final bar = style.bar;

          final Duration position = controller.position;
          final Duration end = controller.duration;
          final double width = constraints.maxWidth;

          return ValueListenableBuilder(
            valueListenable: _progressBarDraggingBuffer,
            builder: (_, Duration value, ___) {
              final Duration draggingPosition =
                  controller.isDraggingProgressBar ? value : position;
              final double progressWidth =
                  (draggingPosition.inMilliseconds / end.inMilliseconds) *
                      width;

              return ProgressBarGesture(
                width: width,
                child: Padding(
                    padding: EdgeInsets.only(bottom: style.paddingBeetwen),
                    child: Stack(
                      alignment: AlignmentDirectional.centerStart,
                      children: [
                        ProgressBar(width: width, color: bar.background),
                        ProgressBar(
                          color: bar.secondBackground,
                          width: (controller.maxBuffering.inMilliseconds /
                                  end.inMilliseconds) *
                              width,
                        ),
                        ProgressBar(width: progressWidth, color: bar.color),
                        DotIsDragging(width: width, dotPosition: progressWidth),
                        Dot(width: width, dotPosition: progressWidth),
                        CustomOpacityTransition(
                          visible: controller.isDraggingProgressBar,
                          child: CustomPaint(
                            painter: _TextPositionPainter(
                              position: draggingPosition,
                              barStyle: style,
                              width: progressWidth,
                              totalWidth: width,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              );
            },
          );
        },
      ),
    );
  }
}

class ProgressBarGesture extends StatefulWidget {
  const ProgressBarGesture({
    super.key,
    required this.child,
    required this.width,
  });

  final Widget child;
  final double width;

  @override
  ProgressBarGestureState createState() => ProgressBarGestureState();
}

class ProgressBarGestureState extends State<ProgressBarGesture> {
  final VideoQuery _query = VideoQuery();

  ValueNotifier<Duration> get videoPosition {
    return Provider.of<ValueNotifier<Duration>>(context, listen: false);
  }

  set animationMilliseconds(int value) {
    Provider.of<ValueNotifier<int>>(context, listen: false).value = value;
  }

  void _seekToRelativePosition(Offset local, [bool showText = false]) {
    final controller = _query.video(context);
    final Duration duration = controller.duration;
    final double localPos = local.dx / widget.width;
    final Duration position = duration * localPos;

    if (position >= Duration.zero && position <= duration) {
      videoPosition.value = position;
    }
  }

  Future<void> play() async {
    animationMilliseconds = 1000;
    await _query.video(context).play();
  }

  Future<void> pause() async {
    animationMilliseconds = 0;
    await _query.video(context).video?.pause();
  }

  void _startDragging() {
    _query.video(context).isDraggingProgressBar = true;
  }

  Future<void> _endDragging() async {
    final controller = _query.video(context);
    await controller.seekTo(controller.beginRange + videoPosition.value);
    controller.isDraggingProgressBar = false;
    if (controller.activeAd == null) await play();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) {
        _startDragging();
        pause();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        _seekToRelativePosition(details.localPosition, true);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        _endDragging();
      },
      onTapDown: (TapDownDetails details) {
        _startDragging();
        _seekToRelativePosition(details.localPosition);
        pause();
      },
      onTapUp: (TapUpDetails details) {
        _seekToRelativePosition(details.localPosition);
        _endDragging();
      },
      child: widget.child,
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({super.key, required this.width, required this.color});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    final animation = Provider.of<ValueNotifier<int>>(context);
    final style = VideoQuery().videoStyle(context).progressBarStyle;

    return AnimatedContainer(
      width: width,
      height: style.bar.height,
      duration: Duration(milliseconds: animation.value),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: style.bar.borderRadius,
      ),
    );
  }
}

class DotIsDragging extends StatelessWidget {
  const DotIsDragging({
    super.key,
    required this.width,
    required this.dotPosition,
  });

  final double dotPosition;
  final double width;

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final controller = query.video(context, listen: true);
    final style = query.videoStyle(context).progressBarStyle;

    final double dotWidth = style.bar.identifierWidth;

    return BooleanTween(
      animate: controller.isDraggingProgressBar &&
          (dotPosition > dotWidth) &&
          (dotPosition < width - dotWidth),
      tween: Tween<double>(begin: 0, end: 0.4),
      builder: (_, double value, __) => Dot(
        width: width,
        dotPosition: dotPosition,
        opacity: value,
        multiplicator: 2,
      ),
    );
  }
}

class Dot extends StatelessWidget {
  const Dot({
    super.key,
    required this.width,
    required this.dotPosition,
    this.opacity = 1,
    this.multiplicator = 1,
  });

  final double dotPosition;
  final int multiplicator;
  final double? width, opacity;

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final animation = Provider.of<ValueNotifier<int>>(context);
    final style = query.videoStyle(context).progressBarStyle;

    final double dotSize = style.bar.identifierWidth;

    final double dotWidth = dotSize * 2;
    final double width = dotPosition < dotSize
        ? dotWidth
        : dotPosition + dotSize * multiplicator;

    return ValueListenableBuilder(
      valueListenable: animation,
      builder: (_, int value, __) {
        return AnimatedContainer(
          width: width,
          duration: Duration(milliseconds: value),
          alignment: Alignment.centerRight,
          child: Container(
            height: dotWidth * multiplicator,
            width: dotWidth * multiplicator,
            decoration: BoxDecoration(
              color: style.bar.identifier.withOpacity(opacity!),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _TextPositionPainter extends CustomPainter {
  _TextPositionPainter({
    this.width,
    this.position,
    this.style,
    this.barStyle,
    this.totalWidth,
  });

  final ProgressBarStyle? barStyle;
  final Duration? position;
  final TextStyle? style;
  final double? width;
  final double? totalWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final text = VideoQuery().durationFormatter(position!);
    final textStyle = ui.TextStyle(
      color: style!.color,
      fontSize: style!.fontSize! + 1,
      fontFamily: style!.fontFamily,
      fontWeight: style!.fontWeight,
      fontStyle: style!.fontStyle,
      fontFamilyFallback: style!.fontFamilyFallback,
      fontFeatures: style!.fontFeatures,
      foreground: style!.foreground,
      background: style!.background,
      letterSpacing: style!.letterSpacing,
      wordSpacing: style!.wordSpacing,
      height: style!.height,
      locale: style!.locale,
      textBaseline: style!.textBaseline,
      decorationColor: style!.decorationColor,
      decoration: style!.decoration,
      decorationStyle: style!.decorationStyle,
      decorationThickness: style!.decorationThickness,
      shadows: style!.shadows,
    );

    final paragraphStyle = ui.ParagraphStyle(textDirection: TextDirection.ltr);
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);

    final paragraph = paragraphBuilder.build();
    paragraph.layout(const ui.ParagraphConstraints(width: 100));

    final height = barStyle!.bar.height;
    final padding = barStyle!.paddingBeetwen;
    final minWidth = paragraph.minIntrinsicWidth;
    final doubleHeight = height * 2;

    final xPos = (totalWidth ?? size.width) / 2 - (minWidth + height * 4) / 2;

    final yPos = -(paragraph.height + doubleHeight + padding);

    final offset = Offset(
      xPos + doubleHeight,
      yPos + height,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          xPos,
          yPos,
          minWidth + height * 4,
          paragraph.height + doubleHeight,
        ),
        barStyle!.bar.borderRadius.topLeft,
      ),
      Paint()..color = barStyle!.backgroundColor,
    );
    canvas.drawParagraph(paragraph, offset);
  }

  @override
  bool shouldRebuildSemantics(_TextPositionPainter oldDelegate) => false;

  @override
  bool shouldRepaint(_TextPositionPainter oldDelegate) {
    return oldDelegate.position != position || oldDelegate.width != width;
  }
}
