import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kenji_player/kenji_player.dart';

class HlsVideoPlayer extends StatefulWidget {
  const HlsVideoPlayer({Key? key}) : super(key: key);

  @override
  State<HlsVideoPlayer> createState() => HlsVideoPlayerState();
}

class HlsVideoPlayerState extends State<HlsVideoPlayer>
    with WidgetsBindingObserver {
  late GlobalKey _playerKey;
  late KenjiPlayerController _controller;
  final Map<String, String> customHeaders = {
    'Authorization':
        'Bearer your_ultra_secure_hls_token_minimum_32_characters_long',
    'User-Agent': 'MyCustomApp/1.0',
    'Custom-Header': 'custom_value',
  };

  @override
  void initState() {
    _playerKey = GlobalKey();
    _controller = KenjiPlayerController();
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
      child:
          Scaffold(backgroundColor: Colors.blueGrey, body: _buildM3U8Player()),
    );
  }

  Widget _buildM3U8Player() {
    return FutureBuilder<Map<String, VideoSource>>(
      future: VideoSource.fromM3u8PlaylistUrl(
        'http://169.254.1.199:7785/storage/media/hls/0a5454c0-36ba-4219-b98d-8994ac0f6af5/master.m3u8',
        httpHeaders: customHeaders, // M3U8-д headers нэмэх
        formatter: (quality) =>
            quality == 'Auto' ? 'Automatic' : '${quality.split('x').last}p',
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return KenjiPlayer(
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
            brightness: true, // 1
            volume: true, // 1
            autoPlay: true, // 1
            caption: true,
            style: CustomKenjiPlayerStyle(
                context: context, controller: _controller),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class CustomKenjiPlayerStyle extends KenjiPlayerStyle {
  CustomKenjiPlayerStyle({
    required BuildContext context,
    required KenjiPlayerController controller,
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
              child: const Text(
                'Hi',
                style: TextStyle(color: Colors.white),
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
