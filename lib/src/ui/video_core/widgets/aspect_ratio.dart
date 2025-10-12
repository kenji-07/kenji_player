import 'package:flutter/material.dart';
import 'package:animax_player/src/data/repositories/video.dart';

class VideoCoreAspectRadio extends StatelessWidget {
  const VideoCoreAspectRadio({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = VideoQuery().video(context).video!;
    return AspectRatio(aspectRatio: controller.value.aspectRatio, child: child);
  }
}
