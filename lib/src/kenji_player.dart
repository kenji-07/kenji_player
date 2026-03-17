import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:kenji_player/src/domain/bloc/controller.dart';
import 'package:kenji_player/src/domain/bloc/metadata.dart';
import 'package:kenji_player/src/domain/entities/styles/kenji_player.dart';
import 'package:kenji_player/src/domain/entities/video_source.dart';
import 'package:kenji_player/src/ui/video_core/video_core.dart';
import 'package:kenji_player/src/ui/widgets/helpers.dart';
import 'package:kenji_player/src/domain/entities/options/positioned_options.dart';

export 'package:video_player/video_player.dart';
export 'package:kenji_player/src/domain/bloc/controller.dart';
export 'package:kenji_player/src/domain/entities/ads.dart';
export 'package:kenji_player/src/domain/entities/styles/kenji_player.dart';
export 'package:kenji_player/src/domain/entities/subtitle.dart';
export 'package:kenji_player/src/domain/entities/video_source.dart';
export 'package:kenji_player/src/domain/entities/options/positioned_options.dart';

class KenjiPlayer extends StatefulWidget {
  const KenjiPlayer({
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
    this.options = const PositionedOptions(),
  });

  final Duration seekTo;
  final String? imaAdTagUrl;
  final Duration opStart;
  final Duration opEnd;
  final Duration edStart;
  final Duration edEnd;
  final bool autoPlay;
  final bool looping;
  final KenjiPlayerStyle? style;
  final double defaultAspectRatio;
  final int rewindAmount;
  final int forwardAmount;
  final Map<String, VideoSource> source;
  final KenjiPlayerController? controller;
  final bool enableFullscreenScale;
  final bool volume;
  final bool brightness;
  final bool lock;
  final bool caption;
  final BoxFit aspect;
  final PositionedOptions options;

  @override
  KenjiPlayerState createState() => KenjiPlayerState();
}

class KenjiPlayerState extends State<KenjiPlayer> {
  late KenjiPlayerController _controller;
  late KenjiPlayerStyle _style;
  bool _initialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? KenjiPlayerController();
    _style = widget.style ?? KenjiPlayerStyle();
    _initKenjiPlayer();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initKenjiPlayer() async {
    try {
      _controller.looping = widget.looping;
      _controller.isShowingThumbnail = _style.thumbnail != null;

      final bool hasAdTagUrl =
          widget.imaAdTagUrl != null && widget.imaAdTagUrl!.isNotEmpty;

      if (hasAdTagUrl) {
        _controller.setImaAdTagUrl(widget.imaAdTagUrl!);
        await _controller.setAdLoadingState(true);
      } else {
        await _controller.setAdLoadingState(false);
      }

      await _controller.initialize(
        widget.source,
        autoPlay: widget.autoPlay,
        seekTo: widget.seekTo,
      );

      if (hasAdTagUrl) {
        _controller.video?.addListener(() {
          if (_controller.video!.value.isCompleted) {
            _controller.adsLoader?.contentComplete();
          }
        });
      }

      if (!mounted) return;
      setState(() {
        _initialized = true;
        _initError = null;
      });
    } catch (e) {
      debugPrint('KenjiPlayer init error: $e');
      if (!mounted) return;
      setState(() {
        _initialized = false;
        _initError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget? thumbnail = _style.thumbnail;

    if (_initError != null) {
      return AspectRatio(
          aspectRatio: widget.defaultAspectRatio,
          child: Stack(
            children: [
              Container(
                color: Colors.black,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.white70, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'Failed to load the video',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _initError!,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 11),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              setState(() => _initError = null);
                              _initKenjiPlayer();
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Icon(PhosphorIcons.caretLeft()),
                ),
              ),
            ],
          ));
    }

    return _initialized
        ? MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: _controller),
              Provider(
                create: (_) => KenjiPlayerMetadata(
                    style: _style,
                    rewindAmount: widget.rewindAmount,
                    forwardAmount: widget.forwardAmount,
                    defaultAspectRatio: widget.defaultAspectRatio,
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
                    options: widget.options),
              ),
            ],
            builder: (context, child) {
              _controller.context = context;
              return const KenjiPlayerCore();
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
                    child: Icon(PhosphorIcons.caretLeft()),
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
                      child: _style.loading,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
