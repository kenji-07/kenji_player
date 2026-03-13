import 'package:flutter/material.dart';
import 'package:kenji_player/src/data/repositories/video.dart';
import 'package:kenji_player/src/ui/widgets/transitions.dart';
import 'package:kenji_player/src/ui/widgets/center_play_and_pause.dart';

class VideoCoreThumbnail extends StatelessWidget {
  const VideoCoreThumbnail({super.key});

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final controller = query.video(context, listen: true);
    final style = query.videoStyle(context);

    final Widget? thumbnail = style.thumbnail;

    return CustomOpacityTransition(
      visible: controller.isShowingThumbnail,
      child: Stack(
        children: [
          if (thumbnail != null) Positioned.fill(child: thumbnail),
          const Center(
            child: CenterPlayAndPause(
              type: CenterPlayAndPauseType.center,
              showRewind: false,
              showForward: false,
            ),
          ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () async {
                await controller.play();
                controller.showAndHideOverlay();
              },
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}
