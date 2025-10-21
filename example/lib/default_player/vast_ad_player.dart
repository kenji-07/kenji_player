import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kenji_player/kenji_player.dart';

import '../utils/environment.dart';

class VastADVideoPlayer extends StatefulWidget {
  const VastADVideoPlayer({Key? key}) : super(key: key);

  @override
  State<VastADVideoPlayer> createState() => VastADVideoPlayerState();
}

class VastADVideoPlayerState extends State<VastADVideoPlayer>
    with WidgetsBindingObserver {
  late GlobalKey _playerKey;
  late KenjiPlayerController _controller;
  final Map<String, String> customHeaders = {};

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
      child: Scaffold(backgroundColor: Colors.blueGrey, body: _buildPlayer()),
    );
  }

  Widget _buildPlayer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: KenjiPlayer(
        seekTo: const Duration(milliseconds: 0),
        opStart: const Duration(seconds: 1),
        opEnd: const Duration(seconds: 10),
        edStart: const Duration(seconds: 15),
        edEnd: const Duration(seconds: 20),
        key: _playerKey,
        controller: _controller,
        lock: true,
        control: false,
        brightness: true,
        volume: true,
        autoPlay: true,
        caption: true,
        imaAdTagUrl:
            'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpremidpost&ciu_szs=300x250&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&impl=s&cmsid=496&vid=short_onecue&correlator=',
        style: CustomKenjiPlayerStyle(
          context: context,
          controller: _controller,
        ),
        source: {
          for (var i = 0; i < Environment.resolutionsUrls.length; i++)
            Environment.resolutionsUrls[i].quality: VideoSource(
              intialSubtitle: Environment.intialSubtitle ?? 'English',
              video: VideoPlayerController.networkUrl(
                  Uri.parse(Environment.resolutionsUrls[i].qualityUrl),
                  httpHeaders: customHeaders),
              httpHeaders: customHeaders,
              subtitle: {
                for (var a = 0; a < Environment.subtitleUrls.length; a++)
                  Environment.subtitleUrls[a].subtitleLang:
                      KenjiPlayerSubtitle.network(
                    Environment.subtitleUrls[a].subtitleUrl,
                    type: SubtitleType.webvtt,
                  ),
              },
            ),
        },
      ),
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
