import 'package:flutter/material.dart';
import 'package:animax_player/src/data/repositories/video.dart';
import 'package:animax_player/src/ui/widgets/helpers.dart';

enum CenterPlayAndPauseType { center, bottom }

class CenterPlayAndPause extends StatelessWidget {
  const CenterPlayAndPause({super.key, required this.type, this.padding});

  final CenterPlayAndPauseType type;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final controller = query.video(context, listen: true);
    final style = query.videoMetadata(context).style.centerPlayAndPauseStyle;
    final bool isPlaying = !controller.isPlaying;

    return SplashCircularIcon(
      onTap: controller.playOrPause,
      padding: padding,
      child: type == CenterPlayAndPauseType.bottom
          ? isPlaying
              ? style.play
              : style.pause
          : controller.position >= controller.duration
              ? style.replayWidget
              : isPlaying
                  ? style.playWidget
                  : style.pauseWidget,
    );
  }
}
