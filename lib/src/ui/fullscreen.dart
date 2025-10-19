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
    _systemResetTimer = Misc.periodic(3000, _hideSystemOverlay);
    _setLandscapeFixed();
    super.initState();
  }

  @override
  void dispose() {
    _systemResetTimer.cancel();
    super.dispose();
  }

  Future<void> _setLandscapeFixed() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await _hideSystemOverlay();
  }

  Future<void> _hideSystemOverlay() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PopScope(
        canPop: false, // "back" товчийг дарахыг хориглох
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
