import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:kenji_player/src/data/repositories/video.dart';

class VideoCorePlayer extends StatefulWidget {
  const VideoCorePlayer({super.key});

  @override
  VideoCorePlayerState createState() => VideoCorePlayerState();
}

class VideoCorePlayerState extends State<VideoCorePlayer> {
  @override
  Widget build(BuildContext context) {
    final controller = VideoQuery().video(context, listen: true);

    return Center(
      child: AspectRatio(
        aspectRatio: controller.video!.value.aspectRatio,
        child: VideoPlayer(controller.video!),
      ),
    );
  }
}
