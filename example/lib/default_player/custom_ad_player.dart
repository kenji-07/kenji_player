import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kenji_player/kenji_player.dart';
import 'package:get/get.dart';
import '../utils/environment.dart';

class CustomADPlayer extends StatefulWidget {
  CustomADPlayer({Key? key}) : super(key: key);

  @override
  State<CustomADPlayer> createState() => CustomADPlayerState();
}

class CustomADPlayerState extends State<CustomADPlayer>
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
      onPopInvokedWithResult: (bool didPop, FormData? result) async {
        if (didPop) {
          return;
        }
      },
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
              ads: [
                KenjiPlayerAd(
                    durationToStart: const Duration(seconds: 0),
                    durationToSkip: const Duration(seconds: 10),
                    deepLink: 'deepLink',
                    child: playerAd(1)),
                KenjiPlayerAd(
                    durationToStart: const Duration(seconds: 20),
                    durationToSkip: const Duration(seconds: 30),
                    deepLink: 'deepLink',
                    child: playerAd(2))
                // Etc.
              ],
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
