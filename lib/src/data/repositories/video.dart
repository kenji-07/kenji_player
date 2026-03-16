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
    final bool isNegative = duration.inSeconds < 0;
    final Duration abs = isNegative ? -duration : duration;

    final int hours = abs.inHours;
    final int minutes = abs.inMinutes.remainder(60);
    final int seconds = abs.inSeconds.remainder(60);

    final String mm = minutes.toString().padLeft(2, '0');
    final String ss = seconds.toString().padLeft(2, '0');

    final String formatted =
        hours > 0 ? '$hours:$mm:$ss' : '$mm:$ss';

    return isNegative ? '-$formatted' : formatted;
  }
}