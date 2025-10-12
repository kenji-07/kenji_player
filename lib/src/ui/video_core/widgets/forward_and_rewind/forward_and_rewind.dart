import 'package:flutter/material.dart';
import 'package:animax_player/src/ui/widgets/transitions.dart';
import 'package:animax_player/src/ui/video_core/widgets/forward_and_rewind/layout.dart';
import 'package:animax_player/src/ui/video_core/widgets/forward_and_rewind/ripple_side.dart';

class VideoCoreForwardAndRewind extends StatelessWidget {
  const VideoCoreForwardAndRewind({
    super.key,
    required this.showRewind,
    required this.showForward,
    required this.forwardSeconds,
    required this.rewindSeconds,
  });

  final bool showRewind, showForward;
  final int rewindSeconds, forwardSeconds;

  @override
  Widget build(BuildContext context) {
    return VideoCoreForwardAndRewindLayout(
      rewind: CustomOpacityTransition(
        visible: showRewind,
        child: ForwardAndRewindRippleSide(
          text: "$rewindSeconds ${"Секунд".toLowerCase()}",
          side: RippleSide.left,
        ),
      ),
      forward: CustomOpacityTransition(
        visible: showForward,
        child: ForwardAndRewindRippleSide(
          text: "+$forwardSeconds ${"Секунд".toLowerCase()}",
          side: RippleSide.right,
        ),
      ),
    );
  }
}
