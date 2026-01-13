import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:kenji_player/src/domain/repositories/video.dart';
import 'package:kenji_player/src/domain/bloc/metadata.dart';
import 'package:kenji_player/src/kenji_player.dart';

class VideoQuery extends VideoQueryRepository {
  @override
  KenjiPlayerMetadata videoMetadata(
    BuildContext context, {
    bool listen = false,
  }) {
    return Provider.of<KenjiPlayerMetadata>(context, listen: listen);
  }

  @override
  KenjiPlayerController video(BuildContext context, {bool listen = false}) {
    return Provider.of<KenjiPlayerController>(context, listen: listen);
  }

  @override
  KenjiPlayerStyle videoStyle(BuildContext context, {bool listen = false}) {
    return Provider.of<KenjiPlayerMetadata>(context, listen: listen).style;
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
