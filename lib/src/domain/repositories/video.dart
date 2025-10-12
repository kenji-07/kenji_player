import 'package:flutter/material.dart';

import 'package:animax_player/src/domain/entities/styles/animax_player.dart';
import 'package:animax_player/src/domain/bloc/controller.dart';
import 'package:animax_player/src/domain/bloc/metadata.dart';

abstract class VideoQueryRepository {
  String durationFormatter(Duration duration);
  AnimaxPlayerStyle videoStyle(BuildContext context, {bool listen = false});
  AnimaxPlayerController video(BuildContext context, {bool listen = false});
  AnimaxPlayerMetadata videoMetadata(
    BuildContext context, {
    bool listen = false,
  });
}
