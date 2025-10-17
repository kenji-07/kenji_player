import 'package:flutter/material.dart';
import 'package:animax_player/src/data/repositories/video.dart';
import 'package:video_player/video_player.dart';

class VideoCoreActiveSubtitleText extends StatelessWidget {
  const VideoCoreActiveSubtitleText({super.key});

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final subtitle = query.video(context, listen: true).activeCaptionData;

    final controller = query.video(context, listen: true);
    final bool isFullScreen = controller.isFullScreen;

    final alignment = isFullScreen
        ? query.videoStyle(context).fullscreenSubtitleStyle.alignment
        : query.videoStyle(context).subtitleStyle.alignment;

    final padding = isFullScreen
        ? query.videoStyle(context).fullscreenSubtitleStyle.padding
        : query.videoStyle(context).subtitleStyle.padding;

    final fontSize = isFullScreen
        ? controller.currentSubtitleSize.toDouble()
        : controller.currentSubtitleSize.toDouble() * 0.7;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: ClosedCaption(
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            // backgroundColor: Colors.black,
            height: 1.2,
          ),
          text: subtitle != null ? subtitle.text : "",
        ),
      ),
    );
  }
}
