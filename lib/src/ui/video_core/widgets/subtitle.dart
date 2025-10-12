import 'package:flutter/material.dart';
import 'package:animax_player/src/data/repositories/video.dart';
import 'package:video_player/video_player.dart';

class VideoCoreActiveSubtitleText extends StatelessWidget {
  const VideoCoreActiveSubtitleText({super.key});

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final style = query.videoStyle(context).subtitleStyle;
    final fullStyle = query.videoStyle(context).fullscreenSubtitleStyle;
    final subtitle = query.video(context, listen: true).activeCaptionData;

    final controller = query.video(context, listen: true);
    final bool isFullScreen = controller.isFullScreen;

    return isFullScreen
        ? Align(
            alignment: fullStyle.alignment,
            child: Padding(
              padding: fullStyle.padding,
              child: ClosedCaption(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  // backgroundColor: Colors.black,
                  height: 1.2,
                ),
                text: subtitle != null ? subtitle.text : "",
              ),
            ),
          )
        : Align(
            alignment: style.alignment,
            child: Padding(
              padding: style.padding,
              child: ClosedCaption(
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  // backgroundColor: Colors.black,
                  height: 1.2,
                ),
                text: subtitle != null ? subtitle.text : "",
              ),
            ),
          );
  }
}
