import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:kenji_player/src/misc.dart';

import 'package:kenji_player/src/data/repositories/video.dart';
import 'package:kenji_player/src/ui/video_core/video_core.dart';

class FullScreenPage extends StatefulWidget {
  const FullScreenPage({super.key});

  @override
  FullScreenPageState createState() => FullScreenPageState();
}

class FullScreenPageState extends State<FullScreenPage> {
  final VideoQuery _query = VideoQuery();
  late Timer _systemResetTimer;

  @override
  void initState() {
    super.initState();
    _systemResetTimer = Misc.periodic(3000, _hideSystemUI);
    _setLandscapeAndHideUI();
  }

  @override
  void dispose() {
    _systemResetTimer.cancel();
    super.dispose();
  }

  Future<void> _setLandscapeAndHideUI() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await _hideSystemUI();
  }

  Future<void> _hideSystemUI() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (!didPop) {
            _systemResetTimer.cancel();
            await _query.video(context).openOrCloseFullscreen();
          }
        },
        child: const KenjiPlayerCore(),
      ),
    );
  }
}