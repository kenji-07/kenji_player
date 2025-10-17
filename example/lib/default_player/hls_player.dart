import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animax_player/animax_player.dart';
import 'package:get/get.dart';

class HlsVideoPlayer extends StatefulWidget {
  HlsVideoPlayer({Key? key}) : super(key: key);

  @override
  State<HlsVideoPlayer> createState() => HlsVideoPlayerState();
}

class HlsVideoPlayerState extends State<HlsVideoPlayer>
    with WidgetsBindingObserver {
  late GlobalKey _playerKey;
  late AnimaxPlayerController _controller;
  final Map<String, String> customHeaders = {
    'Authorization': 'Bearer your_token_here',
    'User-Agent': 'MyCustomApp/1.0',
    'Custom-Header': 'custom_value',
  };

  @override
  void initState() {
    _playerKey = GlobalKey();
    _controller = AnimaxPlayerController();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, FormData? result) async {
        if (didPop) {
          return;
        }
      },
      child:
          Scaffold(backgroundColor: Colors.blueGrey, body: _buildM3U8Player()),
    );
  }

  Widget _buildM3U8Player() {
    return FutureBuilder<Map<String, VideoSource>>(
      future: VideoSource.fromM3u8PlaylistUrl(
        'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        httpHeaders: customHeaders, // M3U8-д headers нэмэх
        formatter: (quality) =>
            quality == 'Auto' ? 'Automatic' : '${quality.split('x').last}p',
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return AnimaxPlayer(
            source: snapshot.data!,
            seekTo: const Duration(
              milliseconds: 0,
            ),
            opStart: const Duration(milliseconds: 0),
            opEnd: const Duration(milliseconds: 0),
            edStart: const Duration(milliseconds: 0),
            edEnd: const Duration(milliseconds: 0),
            key: _playerKey, // 1
            controller: _controller, // 1
            lock: true, // 1 - Ажиллаж байна. 0 - Ажиллахгүй байна.
            control: false, // control block
            brightness: true, // 1
            volume: true, // 1
            autoPlay: true, // 1
            caption: true,
            style: CustomAnimaxPlayerStyle(
                context: context, controller: _controller),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class CustomAnimaxPlayerStyle extends AnimaxPlayerStyle {
  CustomAnimaxPlayerStyle({
    required BuildContext context,
    required AnimaxPlayerController controller,
  }) : super(
          textStyle: const TextStyle(color: Colors.black),
          progressBarStyle: ProgressBarStyle(
            bar: BarStyle.progress(color: Colors.red),
          ),
          header: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            child: InkWell(
              onTap: () async {
                if (controller.isFullScreen) {
                  await controller.openOrCloseFullscreen();
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Hi',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          thumbnail: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.network(
              'https://image.tmdb.org/t/p/original/cm2oUAPiTE1ERoYYOzzgloQw4YZ.jpg',
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              fit: BoxFit.cover,
            ),
          ),
        );
}
