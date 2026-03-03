import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kenji_player/src/ui/widgets/transition.dart';
import 'package:kenji_player/src/data/repositories/video.dart';
import 'package:kenji_player/src/domain/entities/styles/kenji_player.dart';
import 'package:kenji_player/src/ui/widgets/transitions.dart';

class VideoProgressBar extends StatefulWidget {
  const VideoProgressBar({super.key});

  @override
  VideoProgressBarState createState() => VideoProgressBarState();
}

class VideoProgressBarState extends State<VideoProgressBar> {
  final ValueNotifier<Duration> _draggingBuffer =
      ValueNotifier<Duration>(Duration.zero);

  @override
  void dispose() {
    _draggingBuffer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => ValueNotifier<int>(1000)),
        ListenableProvider.value(value: _draggingBuffer),
      ],
      child: LayoutBuilder(
        builder: (_, BoxConstraints constraints) {
          final query = VideoQuery();
          final controller = query.video(context, listen: true);
          final style = query.videoStyle(context).progressBarStyle;
          final bar = style.bar;
          final double width = constraints.maxWidth;
          final Duration position = controller.position;
          final Duration end = controller.duration;

          return ValueListenableBuilder<Duration>(
            valueListenable: _draggingBuffer,
            builder: (_, Duration dragged, __) {
              final Duration displayPos =
                  controller.isDraggingProgressBar ? dragged : position;

              final double progressRatio = end.inMilliseconds > 0
                  ? (displayPos.inMilliseconds / end.inMilliseconds)
                      .clamp(0.0, 1.0)
                  : 0.0;
              final double bufferRatio = end.inMilliseconds > 0
                  ? (controller.maxBuffering.inMilliseconds /
                          end.inMilliseconds)
                      .clamp(0.0, 1.0)
                  : 0.0;

              final double progressWidth = progressRatio * width;
              final double bufferWidth = bufferRatio * width;

              return ProgressBarGesture(
                width: width,
                child: Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: [
                    // Background track
                    ProgressBar(width: width, color: bar.background),
                    // Buffer track
                    ProgressBar(width: bufferWidth, color: bar.secondBackground),
                    // Progress track
                    ProgressBar(width: progressWidth, color: bar.color),
                    // Drag shadow dot
                    DotIsDragging(width: width, dotPosition: progressWidth),
                    // Main dot
                    Dot(width: width, dotPosition: progressWidth),
                    // Time tooltip
                    CustomOpacityTransition(
                      visible: controller.isDraggingProgressBar,
                      child: CustomPaint(
                        painter: _TextPositionPainter(
                          position: displayPos,
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
                ),
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

  ValueNotifier<Duration> get _videoPosition =>
      Provider.of<ValueNotifier<Duration>>(context, listen: false);

  set _animationMilliseconds(int value) =>
      Provider.of<ValueNotifier<int>>(context, listen: false).value = value;

  void _seekToRelativePosition(Offset local) {
    if (widget.width <= 0) return;
    final controller = _query.video(context);
    final Duration duration = controller.duration;
    final double ratio = (local.dx / widget.width).clamp(0.0, 1.0);
    final Duration position = duration * ratio;
    _videoPosition.value = position;
  }

  Future<void> _play() async {
    _animationMilliseconds = 1000;
    await _query.video(context).play();
  }

  Future<void> _pause() async {
    _animationMilliseconds = 0;
    await _query.video(context).pause();
  }

  void _startDragging() {
    _query.video(context).isDraggingProgressBar = true;
  }

  Future<void> _endDragging() async {
    final controller = _query.video(context);
    await controller.seekTo(controller.beginRange + _videoPosition.value);
    controller.isDraggingProgressBar = false;
    if (controller.activeAd == null) await _play();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) {
        _startDragging();
        _pause();
      },
      onHorizontalDragUpdate: (DragUpdateDetails d) {
        _seekToRelativePosition(d.localPosition);
      },
      onHorizontalDragEnd: (_) {
        _endDragging();
      },
      onTapDown: (TapDownDetails d) {
        _startDragging();
        _seekToRelativePosition(d.localPosition);
        _pause();
      },
      onTapUp: (TapUpDetails d) {
        _seekToRelativePosition(d.localPosition);
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
    final double safeWidth = width.clamp(0.0, double.infinity);
    final animation = Provider.of<ValueNotifier<int>>(context);
    final style = VideoQuery().videoStyle(context).progressBarStyle;

    return AnimatedContainer(
      width: safeWidth,
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
          dotPosition > dotWidth &&
          dotPosition < width - dotWidth,
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
    this.opacity = 1.0,
    this.multiplicator = 1,
  });

  final double dotPosition;
  final int multiplicator;
  final double? width;

  final double opacity;

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final animation = Provider.of<ValueNotifier<int>>(context);
    final style = query.videoStyle(context).progressBarStyle;
    final double dotSize = style.bar.identifierWidth;
    final double dotDiameter = dotSize * 2;

    final double containerWidth = dotPosition < dotSize
        ? dotDiameter
        : dotPosition + dotSize * multiplicator;

    return ValueListenableBuilder<int>(
      valueListenable: animation,
      builder: (_, int ms, __) {
        return AnimatedContainer(
          width: containerWidth,
          duration: Duration(milliseconds: ms),
          alignment: Alignment.centerRight,
          child: Container(
            height: dotDiameter * multiplicator,
            width: dotDiameter * multiplicator,
            decoration: BoxDecoration(
              color: style.bar.identifier.withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _TextPositionPainter extends CustomPainter {
  const _TextPositionPainter({
    required this.position,
    required this.barStyle,
    required this.style,
    this.width,
    this.totalWidth,
  });

  final ProgressBarStyle barStyle;
  final Duration position;
  final TextStyle style;
  final double? width;
  final double? totalWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final String text = VideoQuery().durationFormatter(position);
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: text,
        style: style.copyWith(fontSize: (style.fontSize ?? 11) + 1),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 100);

    final double barHeight = barStyle.bar.height;
    final double padding = barStyle.paddingBeetwen;
    final double textW = tp.width;
    final double textH = tp.height;
    final double boxW = textW + barHeight * 4;
    final double boxH = textH + barHeight * 2;

    final double canvasW = totalWidth ?? size.width;
    final double rawX = (width ?? 0) - boxW / 2;
    final double clampedX = rawX.clamp(0.0, canvasW - boxW);
    final double boxY = -(boxH + padding);

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(clampedX, boxY, boxW, boxH),
      barStyle.bar.borderRadius.topLeft,
    );

    canvas.drawRRect(rrect, Paint()..color = barStyle.backgroundColor);
    tp.paint(canvas, Offset(clampedX + barHeight * 2, boxY + barHeight));
  }

  @override
  bool shouldRepaint(_TextPositionPainter old) {
    return old.position != position || old.width != width;
  }

  @override
  bool shouldRebuildSemantics(_TextPositionPainter old) => false;
}