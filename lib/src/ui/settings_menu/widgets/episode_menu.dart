import 'package:flutter/material.dart';
import 'package:kenji_player/src/data/repositories/video.dart';

class EpisodeMenu extends StatelessWidget {
  const EpisodeMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // expo launch
    final VideoQuery query = VideoQuery();
    final style = query.videoStyle(context);

    final Widget? episode = style.episode;

    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 10, top: 20, bottom: 20),
      child: episode,
    );
  }
}
