import 'package:flutter/material.dart';
import 'package:kenji_player/src/data/repositories/video.dart';
import 'package:kenji_player/src/ui/widgets/helpers.dart';

enum CenterPlayAndPauseType { center, bottom }

class CenterPlayAndPause extends StatelessWidget {
  const CenterPlayAndPause({
    super.key,
    required this.type,
    required this.showRewind,
    required this.showForward,
    this.padding,
  });

  final bool showRewind;
  final bool showForward;
  final CenterPlayAndPauseType type;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final controller = query.video(context, listen: true);
    final style = query.videoMetadata(context).style.centerPlayAndPauseStyle;
    final loading = query.videoStyle(context);

    if (controller.isChangingSource || controller.isBuffering) {
      return Container(
        width: loading.centerPlayAndPauseStyle.circleRadius,
        height: loading.centerPlayAndPauseStyle.circleRadius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: loading.centerPlayAndPauseStyle.background,
        ),
        child: SplashCircularIcon(
          onTap: () {},
          padding: padding,
          child: loading.loading,
        ),
      );
    }

    final bool playing = controller.isPlaying;

    Widget childWidget;
    if (showRewind) {
      childWidget = style.rewindWidget;
    } else if (showForward) {
      childWidget = style.forwardWidget;
    } else if (type == CenterPlayAndPauseType.bottom) {
      childWidget = playing ? style.pause : style.play;
    } else {
      if (!controller.isLive && controller.position >= controller.duration) {
        childWidget = style.replayWidget;
      } else {
        childWidget = playing ? style.pauseWidget : style.playWidget;
      }
    }

    return SplashCircularIcon(
      onTap: controller.playOrPause,
      padding: padding,
      child: childWidget,
    );
  }
}