import 'package:flutter/material.dart';

import 'package:kenji_player/src/domain/entities/styles/kenji_player.dart';
import 'package:kenji_player/src/domain/bloc/controller.dart';
import 'package:kenji_player/src/domain/bloc/metadata.dart';

abstract class VideoQueryRepository {
  String durationFormatter(Duration duration);
  KenjiPlayerStyle videoStyle(BuildContext context, {bool listen = false});
  KenjiPlayerController video(BuildContext context, {bool listen = false});
  KenjiPlayerMetadata videoMetadata(
    BuildContext context, {
    bool listen = false,
  });
}
