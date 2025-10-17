import 'package:flutter/material.dart';

import 'package:animax_player/src/data/repositories/video.dart';
import 'package:animax_player/src/ui/overlay/widgets/progress_bar.dart';
import 'package:animax_player/src/ui/widgets/center_play_and_pause.dart';
import 'package:animax_player/src/ui/widgets/transitions.dart';

class VideoCoreOverlayControlMode extends StatelessWidget {
  final Widget child;
  final bool showRewind;
  final bool showForward;
  final bool showSkipStartButton;
  final bool showSkipEndButton;
  final VoidCallback startButton;
  final VoidCallback endButton;
  const VideoCoreOverlayControlMode({
    super.key,
    required this.child,
    required this.showRewind,
    required this.showForward,
    required this.showSkipStartButton,
    required this.showSkipEndButton,
    required this.startButton,
    required this.endButton,
  });

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final controller = query.video(context, listen: true);
    final bool overlayVisible = controller.isShowingOverlay;

    return CustomOpacityTransition(
      visible: !controller.isShowingThumbnail,
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) => CustomOpacityTransition(
              visible: overlayVisible ||
                  controller.isChangingSource ||
                  controller.isBuffering,
              child: Center(
                child: CenterPlayAndPause(
                  type: CenterPlayAndPauseType.center,
                  showForward: showForward,
                  showRewind: showRewind,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            // widthFactor: widthFactor,
            // heightFactor: heightFactor,
            child: const VideoProgressBar(),
          ),
        ],
      ),
    );
  }
}
