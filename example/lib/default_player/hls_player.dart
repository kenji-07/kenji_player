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
        'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8',
        httpHeaders: customHeaders,
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
            key: _playerKey,
            controller: _controller,
            lock: true,
            brightness: true, 
            volume: true,
            autoPlay: true,
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
