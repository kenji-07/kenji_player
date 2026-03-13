import 'package:flutter/material.dart';
import 'package:kenji_player/src/data/repositories/video.dart';
import 'package:video_player/video_player.dart';

class VideoCoreActiveSubtitleText extends StatelessWidget {
  const VideoCoreActiveSubtitleText({super.key});

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final controller = query.video(context, listen: true);
    final subtitle = controller.activeCaptionData;
    final bool isFullScreen = controller.isFullScreen;
    final style = query.videoStyle(context);

    final alignment = isFullScreen
        ? style.fullscreenSubtitleStyle.alignment
        : style.subtitleStyle.alignment;

    final padding = isFullScreen
        ? style.fullscreenSubtitleStyle.padding
        : style.subtitleStyle.padding;

    final double fontSize = isFullScreen
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
            height: 1.2,
          ),
          text: subtitle?.text ?? '',
        ),
      ),
    );
  }
}