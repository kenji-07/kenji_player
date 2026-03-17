import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kenji_player/kenji_player.dart';

import '../utils/environment.dart';

class ReelPlayer extends StatefulWidget {
  const ReelPlayer({Key? key}) : super(key: key);

  @override
  State<ReelPlayer> createState() => ReelPlayerState();
}

class ReelPlayerState extends State<ReelPlayer> with WidgetsBindingObserver {
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
        brightness: false,
        defaultAspectRatio: 9 / 16,
        enableFullscreenScale: false,
        volume: false,
        autoPlay: true,
        caption: true,
        options: const PositionedOptions(
          width: 200,
          height: 200,
          right: 20,
          blur: true,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        style: CustomKenjiPlayerStyle(
          context: context,
          controller: _controller,
        ),
        source: VideoSource.fromNetworkVideoSources(
          {
            for (var i = 0; i < Environment.resolutionsUrls.length; i++)
              Environment.resolutionsUrls[i].quality:
                  'Environment.resolutionsUrls[i].qualityUrl',
          },
          httpHeaders: customHeaders,
          initialSubtitle: 'English',
          subtitle: {
            for (var a = 0; a < Environment.subtitleUrls.length; a++)
              Environment.subtitleUrls[a].subtitleLang:
                  KenjiPlayerSubtitle.network(
                Environment.subtitleUrls[a].subtitleUrl,
                type: SubtitleType.webvtt,
              ),
          },
        ),
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
          buttom: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                alignment: Alignment.centerLeft,
                                child: const Text(
                                  'Sinners',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.normal,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                )),
                            const SizedBox(height: 4),
                            const Text(
                              'Horror, Action, Thriller',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.only(top: 8),
                              constraints: const BoxConstraints(minHeight: 0),
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Trying to leave their troubled lives behind, twin brothers return to their hometown to start again, only to discover that an even greater evil is waiting to welcome them back.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  letterSpacing: 0.3,
                                  fontWeight: FontWeight.w400,
                                  fontStyle: FontStyle.normal,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.only(right: 12),
                        constraints: const BoxConstraints(minWidth: 45),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ListenableBuilder(
                              listenable: controller,
                              builder: (context, _) {
                                return InkWell(
                                  onTap: () => controller.toggleMute(),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.black26,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(3),
                                    child: Icon(
                                      controller.isMuted
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(23),
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Image.network(
                                    'https://image.tmdb.org/t/p/original/fWPgbnt2LSqkQ6cdQc0SZN9CpLm.jpg',
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          thumbnail: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Image.network(
              'https://image.tmdb.org/t/p/original/fWPgbnt2LSqkQ6cdQc0SZN9CpLm.jpg',
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              fit: BoxFit.cover,
            ),
          ),
        );
}
