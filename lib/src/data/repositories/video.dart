import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:animax_player/src/domain/repositories/video.dart';
import 'package:animax_player/src/domain/bloc/metadata.dart';
import 'package:animax_player/src/animax_player.dart';

class VideoQuery extends VideoQueryRepository {
  @override
  AnimaxPlayerMetadata videoMetadata(
    BuildContext context, {
    bool listen = false,
  }) {
    return Provider.of<AnimaxPlayerMetadata>(context, listen: listen);
  }

  @override
  AnimaxPlayerController video(BuildContext context, {bool listen = false}) {
    return Provider.of<AnimaxPlayerController>(context, listen: listen);
  }

  @override
  AnimaxPlayerStyle videoStyle(BuildContext context, {bool listen = false}) {
    return Provider.of<AnimaxPlayerMetadata>(context, listen: listen).style;
  }

  @override
  String durationFormatter(Duration duration) {
    final int hours = duration.inHours;
    final String formatter = [
      if (hours != 0) hours,
      duration.inMinutes,
      duration.inSeconds
    ]
        .map((seg) => seg.abs().remainder(60).toString().padLeft(2, '0'))
        .join(':');
    return duration.inSeconds < 0 ? "-$formatter" : formatter;
  }
}
