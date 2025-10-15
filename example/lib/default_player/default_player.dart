import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:animax_player/animax_player.dart';
import 'package:get/get.dart';
import '../utils/environment.dart';

class AnimaxVideoPlayer extends StatefulWidget {
  final AnimaxPlayerController controller;
  AnimaxVideoPlayer({Key? key, required this.controller}) : super(key: key);

  @override
  State<AnimaxVideoPlayer> createState() => AnimaxVideoPlayerState();
}

class AnimaxVideoPlayerState extends State<AnimaxVideoPlayer>
    with WidgetsBindingObserver {
  late GlobalKey _playerKey;
  int? playerCPosition, videoDuration;
  late final AnimaxPlayerController _controller;

  @override
  void initState() {
    _playerKey = GlobalKey();
    _controller = widget.controller; // widget-ийн controller ашиглах
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
      _setupListener(); // Listener-г тусдаа setup хийх
    });
  }

  void _setupListener() {
    _controller.addListener(() {
      if (!mounted) return;

      // Video initialize болсон эсэхийг шалгах
      if (_controller.video == null) return;

      try {
        final pos = (_controller.position).inMilliseconds;
        final dur = (_controller.duration).inMilliseconds;

        if (pos != playerCPosition || dur != videoDuration) {
          setState(() {
            playerCPosition = pos;
            videoDuration = dur;
          });
          print("playerCPosition :===> $playerCPosition");
          print("videoDuration :===> $videoDuration");
        }
      } catch (e, stackTrace) {
        print("Error in controller listener: $e");
        print("StackTrace: $stackTrace");
      }
    });
  }

  Future<void> _getData() async {
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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
      child: Scaffold(backgroundColor: Colors.blueGrey, body: _ui()),
    );
  }

  Widget _uiHLS() {
    return FutureBuilder<Map<String, VideoSource>>(
        future: VideoSource.fromM3u8PlaylistUrl(
          'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
          formatter: (quality) =>
              quality == 'Auto' ? 'Automatic' : '${quality.split('x').last}p',
        ),
        builder: (_, data) {
          return data.hasData
              ? AnimaxPlayer(
                  source: data.requireData,
                  contentType: 'video/m3u8',
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
                )
              : CircularProgressIndicator();
        });
  }

  Widget _ui() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: AnimaxPlayer(
        contentType: 'video/mp4',
        seekTo: const Duration(
          milliseconds: 0,
        ),
        opStart: const Duration(seconds: 1),
        opEnd: const Duration(seconds: 10),
        edStart: const Duration(seconds: 15),
        edEnd: const Duration(seconds: 20),
        key: _playerKey, // 1
        controller: _controller, // 1
        lock: true, // 1 - Ажиллаж байна. 0 - Ажиллахгүй байна.
        control: false,
        brightness: true, // 1
        volume: true, // 1
        autoPlay: true, // 1
        caption: true,
        imaAdTagUrl:
            'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&impl=s&correlator=',
        style: CustomAnimaxPlayerStyle(
          context: context,
          controller: _controller,
        ),
        source: {
          for (var i = 0; i < Environment.resolutionsUrls.length; i++)
            Environment.resolutionsUrls[i].quality: VideoSource(
              intialSubtitle: Environment.intialSubtitle ?? 'English',
              video: VideoPlayerController.networkUrl(
                Uri.parse(Environment.resolutionsUrls[i].qualityUrl),
              ),
              subtitle: {
                for (var a = 0; a < Environment.subtitleUrls.length; a++)
                  Environment.subtitleUrls[a].subtitleLang:
                      AnimaxPlayerSubtitle.network(
                    Environment.subtitleUrls[a].subtitleUrl,
                    type: SubtitleType.webvtt,
                  ),
              },
              // ads: [
              //   AnimaxPlayerAd(
              //       durationToStart: const Duration(seconds: 0),
              //       durationToSkip: const Duration(seconds: 10),
              //       deepLink: 'deepLink',
              //       child: playerAd(1))
              // ],
            ),
        },
      ),
    );
  }

  Widget playerAd(int type) {
    if (type == 1) {
      return SizedBox(
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
      );
    } else if (type == 2) {
      return Container(
        padding: const EdgeInsets.all(15),
        color: Colors.amber,
        child: Center(
            child: Text(
          'Hiii',
          style: const TextStyle(color: Colors.white, fontSize: 22),
        )),
      );
    } else if (type == 3) {
      return Container(
        color: Colors.amber,
        child: Center(
            child: Text(
          'else Hii',
          style: const TextStyle(color: Colors.white, fontSize: 22),
        )),
      );
      // return ColoredBox(
      //     color: Colors.amber,
      //     child:
      //         VastAdPlayer(url: vastAd.vastAdModel.result![index].url ?? ''));
    } else {
      return Container(
        color: Colors.amber,
        child: Center(
            child: Text(
          'else Hii',
          style: const TextStyle(color: Colors.white, fontSize: 22),
        )),
      );
    }
  }

  Future<bool> onBackPressed() async {
    if (!(kIsWeb)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    print("onBackPressed playerCPosition :===> $playerCPosition");
    print("onBackPressed videoDuration :===> $videoDuration");

    if ((playerCPosition ?? 0) > 0 &&
        (playerCPosition == videoDuration ||
            (playerCPosition ?? 0) > (videoDuration ?? 0))) {
      if (!mounted) return Future.value(false);
      Navigator.pop(context, true);
      return Future.value(true);
    } else if ((playerCPosition ?? 0) > 0) {
      if (!mounted) return Future.value(false);
      Navigator.pop(context, true);
      return Future.value(true);
    } else {
      if (!mounted) return Future.value(false);
      Navigator.pop(context, false);
      return Future.value(true);
    }
  }
}

class CustomAnimaxPlayerStyle extends AnimaxPlayerStyle {
  CustomAnimaxPlayerStyle({
    required BuildContext context,
    required AnimaxPlayerController controller,
  }) : super(
          textStyle: const TextStyle(color: Colors.black),
          // centerPlayAndPauseStyle: CenterPlayAndPauseWidgetStyle(background: Colors.white),
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
              child: Row(
                children: [
                  const Icon(
                    Iconsax.arrow_left_2_copy,
                    size: 15,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      'Hi',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
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
          settingsStyle: SettingsMenuStyle(
            paddingBetweenMainMenuItems: 10,
            items: [
              SettingsMenuItem(
                themed: SettingsMenuItemThemed(
                  title: "Episodes",
                  subtitle: 'episode',
                  icon: const Icon(Iconsax.mobile, color: Colors.white),
                ),
                secondaryMenuWidth: 300,
                secondaryMenu: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Center(
                      child: SizedBox(
                    width: 400,
                    height: MediaQuery.of(context).size.height,
                    child: Image.network(
                      'https://image.tmdb.org/t/p/original/cm2oUAPiTE1ERoYYOzzgloQw4YZ.jpg',
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      fit: BoxFit.cover,
                    ),
                  )),
                ),
              ),
            ],
          ),
        );
}
