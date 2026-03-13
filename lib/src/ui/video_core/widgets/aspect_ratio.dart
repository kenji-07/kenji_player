import 'package:flutter/material.dart';
import 'package:kenji_player/src/data/repositories/video.dart';

class VideoCoreAspectRadio extends StatelessWidget {
  const VideoCoreAspectRadio({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = VideoQuery().video(context);
    final double ratio = controller.video?.value.isInitialized == true
        ? controller.video!.value.aspectRatio
        : VideoQuery().videoMetadata(context).defaultAspectRatio;

    return AspectRatio(aspectRatio: ratio, child: child);
  }
}