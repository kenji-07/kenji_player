import 'package:flutter/material.dart';
import 'package:animax_player/src/data/repositories/video.dart';
import 'package:animax_player/src/ui/widgets/helpers.dart';

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
    final bool isPlaying = !controller.isPlaying;

    Widget childWidget;

    // 1️⃣ Хэрэв rewind эсвэл forward идэвхтэй байвал тэргүүнд шалгана
    if (showRewind) {
      childWidget = style.rewindWidget;
    } else if (showForward) {
      childWidget = style.forwardWidget;
    }
    // 2️⃣ Эс бөгөөс type-аас хамаарна
    else if (type == CenterPlayAndPauseType.bottom) {
      childWidget = isPlaying ? style.play : style.pause;
    } else {
      childWidget = controller.position >= controller.duration
          ? style.replayWidget
          : isPlaying
              ? style.playWidget
              : style.pauseWidget;
    }

    return SplashCircularIcon(
      onTap: controller.playOrPause,
      padding: padding,
      child: childWidget,
    );
  }
}
