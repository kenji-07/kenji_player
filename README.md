# Kenji Video Player

Kenji Video Player is a video player for Flutter.  
The [video_player](https://pub.dev/packages/video_player) plugin gives low level access for the video playback. Kenji Player wraps `video_player` under the hood and provides a base architecture for developers to create their own set of UI and functionalities.

## Features

- Double tap to seek video.
- On video tap play/pause, mute/unmute, or perform any action on video.
- Auto hide controls.
- Subtitle
- Subtitle control
- Custom animations.
- Custom controls for normal and fullscreen.
- Auto-play list of videos.
- Change playback speed.
- Change quality select.
- Custom ads
- Google IMA ads show on player
- Volume & Brightness control
- OP start, OP end & END start, END end - seek
- Screen lock mode
- Thumbnail
- BoxFit for video
- Wakelock
- Custom widget
- HLS (tracks, segmented subtitles)
- Headers
- Etc...

## Example Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kenji_player/kenji_player.dart';

class DefaultVideoPlayer extends StatefulWidget {
  const DefaultVideoPlayer({Key? key}) : super(key: key);

  @override
  State<DefaultVideoPlayer> createState() => DefaultVideoPlayerState();
}

class DefaultVideoPlayerState extends State<DefaultVideoPlayer>
    with WidgetsBindingObserver {
  late GlobalKey _playerKey;
  late KenjiPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _playerKey = GlobalKey();
    _controller = KenjiPlayerController();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: SizedBox(
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
        enableFullscreenScale: true,
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
            ),
           // ads: [
            //    KenjiPlayerAd(
            //        durationToStart: const Duration(seconds: 0),
            //        durationToSkip: const Duration(seconds: 10),
             //       deepLink: 'deepLink',
             //       child: playerAd(1)),
             //   KenjiPlayerAd(
              //      durationToStart: const Duration(seconds: 20),
             //       durationToSkip: const Duration(seconds: 30),
             //       deepLink: 'deepLink',
              //      child: playerAd(2))
                // Etc.
             // ],
        },
      ),
    )
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
              fit: BoxFit.cover,
            ),
          ),
        );
}
# kenji_player
