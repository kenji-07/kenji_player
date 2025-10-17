import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'package:animax_player/src/domain/bloc/controller.dart';
import 'package:animax_player/src/domain/bloc/metadata.dart';
import 'package:animax_player/src/domain/entities/styles/animax_player.dart';
import 'package:animax_player/src/domain/entities/video_source.dart';
import 'package:animax_player/src/ui/video_core/video_core.dart';
import 'package:animax_player/src/ui/widgets/helpers.dart';

export 'package:video_player/video_player.dart';
export 'package:animax_player/src/domain/bloc/controller.dart';
export 'package:animax_player/src/domain/entities/ads.dart';
export 'package:animax_player/src/domain/entities/styles/animax_player.dart';
export 'package:animax_player/src/domain/entities/subtitle.dart';
export 'package:animax_player/src/domain/entities/video_source.dart';

class AnimaxPlayer extends StatefulWidget {
  const AnimaxPlayer({
    super.key,
    required this.source,
    this.style,
    this.controller,
    required this.seekTo,
    this.looping = false,
    this.autoPlay = false,
    this.defaultAspectRatio = 16 / 9,
    this.rewindAmount = -10,
    this.forwardAmount = 10,
    this.control = true,
    this.enableFullscreenScale = true,
    this.volume = false,
    this.brightness = false,
    this.lock = true,
    this.caption = true,
    this.aspect = BoxFit.cover,
    this.imaAdTagUrl,
    required this.opStart,
    required this.opEnd,
    required this.edStart,
    required this.edEnd,
  });

  final Duration seekTo;

  final String? imaAdTagUrl;

  /// OP Start, OP End & END Start, END End
  final Duration opStart;
  final Duration opEnd;
  final Duration edStart;
  final Duration edEnd;

  /// Once the video is initialized, it will be played
  final bool autoPlay;

  ///Sets whether or not the video should loop after playing once.
  final bool looping;

  /// It is an argument where you can change the design of almost the entire AnimaxPlayer
  final AnimaxPlayerStyle? style;

  /// It is the Aspect Ratio that the widget.style.loading will take when the video
  /// is not initialized yet
  final double defaultAspectRatio;

  /// It is the amount of seconds that the video will be delayed when double tapping.
  final int rewindAmount;

  /// It is the amount of seconds that the video will be advanced when double tapping.
  final int forwardAmount;

  final Map<String, VideoSource> source;

  ///If it is `true`, when entering the fullscreen it will be fixed
  ///in landscape mode and it will not be possible to rotate it in portrait.
  ///If it is `false`, you can rotate the entire screen in any position.
  final bool control;

  /// Controls a platform video PLAYER, and provides updates when the state is
  /// changing.
  ///
  /// Instances must be initialized with initialize.
  ///...
  /// The video is displayed in a Flutter app by creating a [VideoPlayer] widget.
  ///
  /// To reclaim the resources used by the player call [dispose].
  ///
  /// After [dispose] all further calls are ignored.
  final AnimaxPlayerController? controller;

  ///When the video is fullscreen and landscape mode, It's able to scale itself until the screen boundaries
  final bool enableFullscreenScale;

  ///On VerticalSwapingGesture the video is able to control the **video volume** or **device volume**.
  final bool volume;

  ///On HorizontalSwapingGesture the video is able to control the forward and rewind of itself
  final bool brightness;

  /// this class helps you to hide some player lock button
  final bool lock;

  /// this class helps you to hide some player  Caption
  final bool caption;

  final BoxFit aspect;

  @override
  AnimaxPlayerState createState() => AnimaxPlayerState();
}

class AnimaxPlayerState extends State<AnimaxPlayer> {
  late AnimaxPlayerController _controller;
  late AnimaxPlayerStyle _style;
  bool _initialized = false;

  @override
  void initState() {
    _controller = widget.controller ?? AnimaxPlayerController();
    _style = widget.style ?? AnimaxPlayerStyle();
    _initAnimaxPlayer();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initAnimaxPlayer() async {
    _controller.looping = widget.looping;
    _controller.isShowingThumbnail = _style.thumbnail != null;

    // IMA Ad Tag URL шалгах
    final bool hasAdTagUrl =
        widget.imaAdTagUrl != null && widget.imaAdTagUrl!.isNotEmpty;

    if (hasAdTagUrl) {
      // Ad байгаа үед төлөвийг тохируулах
      _controller.setImaAdTagUrl(widget.imaAdTagUrl!);
      await _controller.setAdLoadingState(true);
    } else {
      // Ad байхгүй үед
      await _controller.setAdLoadingState(false);
    }

    // Video initialize хийх
    await _controller.initialize(widget.source, autoPlay: widget.autoPlay);

    // Video дууссаныг мэдэгдэх
    if (hasAdTagUrl) {
      _controller.video?.addListener(() {
        if (_controller.video!.value.isCompleted) {
          _controller.adsLoader?.contentComplete();
        }
      });
    }

    if (!mounted) return;
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final Widget? thumbnail = _style.thumbnail;
    return _initialized
        ? MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: _controller),
              Provider(
                create: (_) => AnimaxPlayerMetadata(
                  style: _style,
                  rewindAmount: widget.rewindAmount,
                  forwardAmount: widget.forwardAmount,
                  defaultAspectRatio: widget.defaultAspectRatio,
                  control: widget.control,
                  enableFullscreenScale: widget.enableFullscreenScale,
                  volume: widget.volume,
                  brightness: widget.brightness,
                  lock: widget.lock,
                  caption: widget.caption,
                  aspect: widget.aspect,
                  opStart: widget.opStart,
                  opEnd: widget.opEnd,
                  edStart: widget.edStart,
                  edEnd: widget.edEnd,
                ),
              ),
            ],
            builder: (context, child) {
              _controller.context = context;
              return const AnimaxPlayerCore();
            },
          )
        : AspectRatio(
            aspectRatio: widget.defaultAspectRatio,
            child: Stack(
              children: [
                if (thumbnail != null) Positioned.fill(child: thumbnail),
                Positioned(
                  top: 20,
                  left: 20,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Iconsax.arrow_left_2_copy),
                  ),
                ),
                Center(
                    child: Container(
                  width: _style.centerPlayAndPauseStyle.circleRadius,
                  height: _style.centerPlayAndPauseStyle.circleRadius,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _style.centerPlayAndPauseStyle.background,
                  ),
                  child: SplashCircularIcon(
                    onTap: () {},
                    // padding: padding,
                    child: _style.loading,
                  ),
                )),
              ],
            ),
          );
  }
}
