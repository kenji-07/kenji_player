import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter/services.dart';

import 'package:kenji_player/src/misc.dart';

import 'package:kenji_player/src/data/repositories/video.dart';
import 'package:kenji_player/src/volume_brightness.dart';
import 'package:kenji_player/src/domain/bloc/controller.dart';
import 'package:kenji_player/src/ui/video_core/widgets/ad.dart';
import 'package:kenji_player/src/ui/widgets/helpers.dart';

import 'package:kenji_player/src/ui/video_core/widgets/forward_and_rewind/layout.dart';
import 'package:kenji_player/src/ui/video_core/widgets/aspect_ratio.dart';
import 'package:kenji_player/src/ui/video_core/widgets/orientation.dart';
import 'package:kenji_player/src/ui/video_core/widgets/thumbnail.dart';
import 'package:kenji_player/src/ui/video_core/widgets/subtitle.dart';
import 'package:kenji_player/src/ui/video_core/widgets/player.dart';
import 'package:kenji_player/src/ui/widgets/center_play_and_pause.dart';
import 'package:kenji_player/src/ui/widgets/transitions.dart';
import 'package:kenji_player/src/ui/overlay/overlay.dart';
import 'package:kenji_player/src/ui/overlay/overlay_control_mode.dart';
import 'package:kenji_player/src/ui/settings_menu/widgets/speed_menu.dart';
import 'package:kenji_player/src/ui/settings_menu/widgets/aspect_menu.dart';
import 'package:kenji_player/src/ui/settings_menu/widgets/caption_menu.dart';
import 'package:kenji_player/src/ui/settings_menu/widgets/quality_menu.dart';
import 'package:kenji_player/src/ui/settings_menu/widgets/episode_menu.dart';

class KenjiPlayerCore extends StatefulWidget {
  const KenjiPlayerCore({super.key});

  @override
  KenjiPlayerCoreState createState() => KenjiPlayerCoreState();
}

class KenjiPlayerCoreState extends State<KenjiPlayerCore> {
  final VideoQuery _query = VideoQuery();

  /// Variables for swipe to adjust volume/brightness
  bool longPress = false;
  bool _dragLeft = false;
  double? _volume;
  double? _brightness;
  late StreamController<double> _streamController;

  /// OP & END skip
  bool showSkipStartButton = false;
  bool showSkipEndButton = false;
  StreamSubscription? _positionListener;

  /// Variables for seek to function
  Duration currentPos = const Duration();
  double currentPlaybackSpeed = 1.0;

  /// Variables for showing current battery status
  final Battery battery = Battery();
  StreamSubscription? batteryStateListener;
  BatteryState? batteryState;
  int batteryLevel = 0;
  late Timer batteryTimer;

  //------------------------------//
  //REWIND AND FORWARD (VARIABLES)//
  //------------------------------//
  final ValueNotifier<int> _forwardAndRewindSecondsAmount = ValueNotifier<int>(
    1,
  );
  int rewindDoubleTapCounts = 0;
  int forwardDoubleTapCount = 0;
  int _defaultRewindAmount = -10;
  int _defaultForwardAmount = 10;
  Timer? _rewindDoubleTapTimer;
  Timer? _forwardDoubleTapTimer;
  List<bool> showAMomentRewindIcons = [false, false];

  //------------------//
  //VOLUME (VARIABLES)//
  //------------------//
  final ValueNotifier<double> _currentVolume = ValueNotifier<double>(1.0);

  Timer? _closeVolumeStatus;

  //-----------------//
  //SCALE (VARIABLES)//
  //-----------------//
  final ValueNotifier<double> _scale = ValueNotifier<double>(1.0);

  @override
  void initState() {
    super.initState();

    Misc.onLayoutRendered(() async {
      final metadata = _query.videoMetadata(context);
      _defaultRewindAmount = metadata.rewindAmount;
      _defaultForwardAmount = metadata.forwardAmount;

      VolumeController.instance.addListener((volume) {});
      _streamController = StreamController.broadcast();

      // Video position listener нэмэх
      _setupPositionListener();

      setState(() {});
    });

    batteryStateListener = battery.onBatteryStateChanged.listen((
      BatteryState state,
    ) {
      if (batteryState == state) return;
      setState(() {
        batteryState = state;
      });
    });
    getBatteryLevel();
    batteryTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      getBatteryLevel();
    });
  }

  void _setupPositionListener() {
    final controller = _query.video(context);

    // Video position өөрчлөгдөх бүрт skip button-уудыг шалгах
    _positionListener = controller.video?.addListener(() {
      _checkSkipButtons();
    }) as StreamSubscription?;
  }

  void _checkSkipButtons() {
    if (!mounted) return;

    final controller = _query.video(context);
    final metadata = _query.videoMetadata(context);
    final position = controller.position;

    // OP Skip товчлуур шалгах
    final shouldShowOpSkip = metadata.opStart != Duration.zero &&
        metadata.opEnd != Duration.zero &&
        position >= metadata.opStart &&
        position < metadata.opEnd;

    // ED Skip товчлуур шалгах
    final shouldShowEdSkip = metadata.edStart != Duration.zero &&
        metadata.edEnd != Duration.zero &&
        position >= metadata.edStart &&
        position < metadata.edEnd;

    // Зөвхөн өөрчлөлт байвал л setState хийх
    if (showSkipStartButton != shouldShowOpSkip ||
        showSkipEndButton != shouldShowEdSkip) {
      setState(() {
        showSkipStartButton = shouldShowOpSkip;
        showSkipEndButton = shouldShowEdSkip;
      });
    }
  }

  @override
  void dispose() {
    _scale.dispose();
    _positionListener?.cancel();
    batteryTimer.cancel();
    batteryStateListener?.cancel();
    _streamController.close();
    VolumeController.instance.removeListener();
    _currentVolume.dispose();
    _closeVolumeStatus?.cancel();
    _rewindDoubleTapTimer?.cancel();
    _forwardDoubleTapTimer?.cancel();
    _forwardAndRewindSecondsAmount.dispose();
    super.dispose();
  }

  double panelHeight() {
    return MediaQuery.of(context).size.height;
  }

  double panelWidth() {
    return MediaQuery.of(context).size.width;
  }

  getBatteryLevel() async {
    final level = await battery.batteryLevel;
    if (mounted) {
      setState(() {
        batteryLevel = level;
      });
    }
  }

  /// vertical drag to adjust volume/brightness
  void onBrightnessStartFun(DragStartDetails d) {
    final metadata = _query.videoMetadata(context);
    final controller = _query.video(context);
    final bool brightnessController = metadata.brightness;
    final bool volumeController = metadata.volume;

    if (_canListenerMove(controller)) {
      if (volumeController && brightnessController) {
        if (d.localPosition.dy > 40 &&
            d.localPosition.dy < panelHeight() - 40) {
          if (d.localPosition.dx > panelWidth() / 2) {
            // right, volume
            _dragLeft = false;
            VolumeController.instance.getVolume().then((value) {
              setState(() {
                _volume = value;
              });
            });
          } else {
            // left, brightness
            _dragLeft = true;
            ScreenBrightness().application.then((value) {
              setState(() {
                _brightness = value;
                _streamController.add(value);
              });
            });
          }
        }
      } else if (volumeController) {
        if (d.localPosition.dy > 40 &&
            d.localPosition.dy < panelHeight() - 40) {
          if (d.localPosition.dx > panelWidth() / 2) {
            // right, volume
            _dragLeft = false;
            VolumeController.instance.getVolume().then((value) {
              setState(() {
                _volume = value;
              });
            });
          } else {
            // left, brightness
            _dragLeft = true;
            VolumeController.instance.getVolume().then((value) {
              setState(() {
                _volume = value;
              });
            });
          }
        }
      } else if (brightnessController) {
        if (d.localPosition.dy > 40 &&
            d.localPosition.dy < panelHeight() - 40) {
          if (d.localPosition.dx > panelWidth() / 2) {
            // right, volume
            _dragLeft = false;
            ScreenBrightness().application.then((value) {
              setState(() {
                _brightness = value;
                _streamController.add(value);
              });
            });
          } else {
            // left, brightness
            _dragLeft = true;
            ScreenBrightness().application.then((value) {
              setState(() {
                _brightness = value;
                _streamController.add(value);
              });
            });
          }
        }
      }
    }
  }

  void onBrightnessUpdateFun(DragUpdateDetails d) {
    final controller = _query.video(context);
    final metadata = _query.videoMetadata(context);
    final bool brightnessController = metadata.brightness;
    final bool volumeController = metadata.volume;
    final bool isFullScreen = controller.isFullScreen;
    double delta;
    if (isFullScreen) {
      delta = d.primaryDelta! / panelHeight();
    } else {
      delta = d.primaryDelta! * 2 / panelHeight();
    }
    delta = -delta.clamp(-1.0, 1.0);
    if (volumeController && brightnessController) {
      if (_dragLeft == false) {
        var volume = _volume;
        if (volume != null) {
          volume += delta;
          volume = volume.clamp(0.0, 1.0);
          _volume = volume;
          VolumeController.instance.showSystemUI = false;
          VolumeController.instance.setVolume(volume);
          VolumeController.instance.showSystemUI = false;
          setState(() {
            _streamController.add(volume!);
          });
        }
      } else if (_dragLeft == true) {
        var brightness = _brightness;
        if (brightness != null) {
          brightness += delta;
          brightness = brightness.clamp(0.0, 1.0);
          _brightness = brightness;
          ScreenBrightness().setApplicationScreenBrightness(brightness);
          setState(() {
            _streamController.add(brightness!);
          });
        }
      }
    } else if (volumeController) {
      if (_dragLeft == false) {
        var volume = _volume;
        if (volume != null) {
          volume += delta;
          volume = volume.clamp(0.0, 1.0);
          _volume = volume;
          VolumeController.instance.showSystemUI = false;
          VolumeController.instance.setVolume(volume);
          VolumeController.instance.showSystemUI = false;
          setState(() {
            _streamController.add(volume!);
          });
        }
      } else if (_dragLeft == true) {
        var volume = _volume;
        if (volume != null) {
          volume += delta;
          volume = volume.clamp(0.0, 1.0);
          _volume = volume;
          VolumeController.instance.showSystemUI = false;
          VolumeController.instance.setVolume(volume);
          VolumeController.instance.showSystemUI = false;
          setState(() {
            _streamController.add(volume!);
          });
        }
      }
    } else if (brightnessController) {
      if (_dragLeft == false) {
        var brightness = _brightness;
        if (brightness != null) {
          brightness += delta;
          brightness = brightness.clamp(0.0, 1.0);
          _brightness = brightness;
          ScreenBrightness().setApplicationScreenBrightness(brightness);
          setState(() {
            _streamController.add(brightness!);
          });
        }
      } else if (_dragLeft == true) {
        var brightness = _brightness;
        if (brightness != null) {
          brightness += delta;
          brightness = brightness.clamp(0.0, 1.0);
          _brightness = brightness;
          ScreenBrightness().setApplicationScreenBrightness(brightness);
          setState(() {
            _streamController.add(brightness!);
          });
        }
      }
    }
  }

  void onBrightnessEndFun(DragEndDetails e) {
    final metadata = _query.videoMetadata(context);
    final bool brightnessController = metadata.brightness;
    final bool volumeController = metadata.volume;
    setState(() {
      if (volumeController && brightnessController) {
        _volume = null;
        _brightness = null;
      } else if (volumeController) {
        _volume = null;
      } else if (brightnessController) {
        _brightness = null;
      }
    });
  }

  //-------------//
  //OVERLAY (TAP)//
  //-------------//

  bool _canListenerMove([KenjiPlayerController? controller]) {
    controller ??= _query.video(context);
    return !(controller.isDraggingProgressBar ||
        controller.activeAd != null ||
        controller.isShowingEpisode);
  }

  //-------------------------------//
  //FORWARD AND REWIND (DOUBLE TAP)//
  //-------------------------------//
  void _rewind() => _showRewindAndForward(0, _defaultRewindAmount);
  void _forward() => _showRewindAndForward(1, _defaultForwardAmount);

  Future<void> _videoSeekToNextSeconds(int seconds) async {
    final controller = _query.video(context);
    final int position = controller.video!.value.position.inSeconds;
    await controller.seekTo(Duration(seconds: position + seconds));
    await controller.play();
  }

  void _showRewindAndForward(int index, int amount) async {
    _videoSeekToNextSeconds(amount);
    final controller = _query.video(context);
    if (_canListenerMove(controller)) {
      if (index == 0) {
        if (!showAMomentRewindIcons[index]) rewindDoubleTapCounts = 0;
        _rewindDoubleTapTimer?.cancel();
        rewindDoubleTapCounts += 1;
        _rewindDoubleTapTimer = Misc.timer(600, () {
          showAMomentRewindIcons[index] = false;
          setState(() {});
        });
      } else {
        if (!showAMomentRewindIcons[index]) forwardDoubleTapCount = 0;
        _forwardDoubleTapTimer?.cancel();
        forwardDoubleTapCount += 1;
        _forwardDoubleTapTimer = Misc.timer(600, () {
          showAMomentRewindIcons[index] = false;
          setState(() {});
        });
      }
    }
    showAMomentRewindIcons[index] = true;
    setState(() {});
  }

  Widget buildDragProgressTimeToast() {
    final controller = _query.video(context);
    final int duration = controller.duration.inSeconds;

    return Offstage(
      offstage: _forwardAndRewindSecondsAmount.value == -1,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, .7),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            "${_query.durationFormatter(Duration(seconds: _forwardAndRewindSecondsAmount.value))} / ${_query.durationFormatter(Duration(seconds: duration))}",
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final controller = query.video(context, listen: true);
    final bool isLock = controller.isLock;
    final bool overlayVisible = controller.isShowingOverlay;

    return VideoCoreOrientation(
      builder: (isFullScreenLandscape) {
        if (controller.isAdLoaded) {
          if (!controller.shouldShowContentVideo) {
            return KeyedSubtree(
              key: const ValueKey('ad_container'),
              child: controller.adDisplayContainer,
            );
          }
        }

        return isLock
            ? isFullScreenLandscape
                ? _playerLock(isFullScreenLandscape, overlayVisible)
                : VideoCoreAspectRadio(
                    child: _playerLock(isFullScreenLandscape, overlayVisible),
                  )
            : isFullScreenLandscape
                ? _global(isFullScreenLandscape, overlayVisible)
                : VideoCoreAspectRadio(
                    child: _global(isFullScreenLandscape, overlayVisible),
                  );
      },
    );
  }

  void onVideoTimeChangeUpdate(double value) {}

  double getCurrentVideoValue() {
    final controller = _query.video(context);
    final double duration = controller.duration.inMilliseconds.toDouble();
    double currentValue;
    if (_forwardAndRewindSecondsAmount.value > 0) {
      currentValue = _forwardAndRewindSecondsAmount.value.toDouble();
    } else {
      currentValue = currentPos.inMilliseconds.toDouble();
    }
    currentValue = min(currentValue, duration);
    currentValue = max(currentValue, 0);
    return currentValue;
  }

  /// Change back to original speed
  void onLongPressUpFunc() {
    final video = _query.video(context);

    setState(() {
      video.video!.setPlaybackSpeed(currentPlaybackSpeed);
      longPress = false;
    });
  }

  /// Change to double speed
  void onLongPressFunc() {
    final controller = _query.video(context);

    if (controller.isPlaying) {
      HapticFeedback.lightImpact();
      setState(() {
        longPress = true;
        controller.video!.setPlaybackSpeed(2.0);
      });
    }
  }

  Widget _global(bool canScale, overlayVisible) {
    final metadata = _query.videoMetadata(context);
    final controller = _query.video(context);
    final bool scale = metadata.control;

    return Stack(
      children: [
        _globalGesture(canScale, overlayVisible),
        if (!scale)
          rightPositioned(controller.isShowingSpeed, const SpeedMenu()),
        if (!scale)
          rightPositioned(controller.isShowingAspect, const AspectMenu()),
        if (!scale)
          rightPositioned(controller.isShowingCaption, const CaptionMenu()),
        if (!scale)
          rightPositioned(controller.isShowingQuality, const QualityMenu()),
        if (!scale)
          rightPositioned(controller.isShowingEpisode, const EpisodeMenu()),
      ],
    );
  }

  //--------//
  //GESTURES//
  //--------//
  Widget _globalGesture(bool canScale, overlayVisible) {
    final metadata = _query.videoMetadata(context);

    final controller = _query.video(context);
    final bool isFullScreen = controller.isFullScreen;
    final bool scale = metadata.control;

    double currentValue = getCurrentVideoValue();

    return !scale
        ? GestureDetector(
            onLongPress: controller.isPlaying ? onLongPressFunc : null,
            onLongPressUp: controller.isPlaying ? onLongPressUpFunc : null,
            onVerticalDragUpdate: isFullScreen ? onBrightnessUpdateFun : null,
            onVerticalDragStart: isFullScreen ? onBrightnessStartFun : null,
            onVerticalDragEnd: isFullScreen ? onBrightnessEndFun : null,
            onHorizontalDragStart: (d) =>
                onVideoTimeChangeUpdate.call(currentValue),
            onHorizontalDragUpdate: (d) {
              double deltaDx = d.delta.dx;
              if (deltaDx == 0) {
                return;
              }
              null;
            },
            onHorizontalDragEnd: (d) {
              null;
            },
            child: _player(overlayVisible),
          )
        : _player(overlayVisible);
  }

  Widget _player(overlayVisible) {
    final controller = _query.video(context, listen: true);
    final bool isFullScreen = controller.isFullScreen;
    final style = _query.videoStyle(context);
    final metadata = _query.videoMetadata(context);
    final bool scale = metadata.control;
    return Stack(
      children: [
        Positioned.fill(
          child: ValueListenableBuilder(
            valueListenable: _scale,
            builder: (_, double scale, __) => Transform.scale(
              scale: scale,
              child: FittedBox(
                clipBehavior: Clip.hardEdge,
                fit: controller.currentAspect,
                child: SizedBox(
                  width: controller.video!.value.size.width != 0
                      ? controller.video!.value.size.width
                      : 640,
                  height: controller.video!.value.size.height != 0
                      ? controller.video!.value.size.height
                      : 480,
                  child: const VideoCorePlayer(),
                ),
              ),
            ),
          ),
        ),

        // ========== END IMA ADS ==========

        if (!scale) const VideoCoreActiveSubtitleText(),
        GestureDetector(
          onTap: () => _query.video(context).showAndHideOverlay(),
          behavior: HitTestBehavior.opaque,
          child: const SizedBox(
            height: double.infinity,
            width: double.infinity,
          ),
        ),

        if (!scale)
          GestureDetector(
            onTap: () => _query.video(context).showAndHideOverlay(),
            behavior: HitTestBehavior.opaque,
            child: CustomOpacityTransition(
              visible: overlayVisible,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),

        VideoCoreForwardAndRewindLayout(
          rewind: GestureDetector(onDoubleTap: _rewind),
          forward: GestureDetector(onDoubleTap: _forward),
        ),

        Builder(
          builder: (_) {
            final controller = _query.video(context, listen: true);

            return CustomOpacityTransition(
              visible: (controller.position >= controller.duration &&
                      !controller.isShowingOverlay) ||
                  showAMomentRewindIcons[0] ||
                  showAMomentRewindIcons[1] ||
                  controller.isChangingSource ||
                  controller.isBuffering,
              child: Center(
                child: CenterPlayAndPause(
                  type: CenterPlayAndPauseType.center,
                  showRewind: showAMomentRewindIcons[0],
                  showForward: showAMomentRewindIcons[1],
                ),
              ),
            );
          },
        ),
        if (scale)
          VideoCoreOverlayControlMode(
            showRewind: showAMomentRewindIcons[0],
            showForward: showAMomentRewindIcons[1],
            showSkipStartButton: showSkipStartButton,
            showSkipEndButton: showSkipEndButton,
            startButton: () {
              controller.seekTo(metadata.opEnd);
              setState(() {
                showSkipStartButton = false;
              });
            },
            endButton: () {
              controller.seekTo(metadata.edEnd);
              // Товчлуур дарсны дараа шууд нуух
              setState(() {
                showSkipEndButton = false;
              });
            },
            child: isFullScreen
                ? SizedBox(
                    height: 14,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Row(
                        children: [
                          const Spacer(),
                          buildTimeNow(),
                          const Spacer(),
                          buildPower(),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        if (!scale)
          VideoCoreOverlay(
            showRewind: showAMomentRewindIcons[0],
            showForward: showAMomentRewindIcons[1],
            showSkipStartButton: showSkipStartButton,
            showSkipEndButton: showSkipEndButton,
            startButton: () {
              controller.seekTo(metadata.opEnd);
              setState(() {
                showSkipStartButton = false;
              });
            },
            endButton: () {
              controller.seekTo(metadata.edEnd);
              // Товчлуур дарсны дараа шууд нуух
              setState(() {
                showSkipEndButton = false;
              });
            },
            child: isFullScreen
                ? SizedBox(
                    height: 14,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Row(
                        children: [
                          const Spacer(),
                          buildTimeNow(),
                          const Spacer(),
                          buildPower(),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

        if (!scale)
          if (metadata.lock)
            CustomOpacityTransition(
              visible: controller.isShowingOverlay,
              child: Align(
                alignment: Alignment.centerLeft,
                child: SplashCircularIcon(
                  padding: EdgeInsets.only(
                    left: isFullScreen ? 80 : 20,
                  ),
                  onTap: () => controller.openLock(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.3),
                      // borderRadius: BorderRadius.circular(7),
                    ),
                    child:
                        controller.isLock ? style.lock.locked : style.lock.lock,
                  ),
                ),
              ),
            ),

        if (!scale)
          Align(
            alignment: Alignment.topCenter,
            child: buildLongPressSpeedToast(),
          ),

        if (!scale) volumeBrightnessToast(),
        const VideoCoreThumbnail(),

        if (!scale) const VideoCoreAdViewer(),
      ],
    );
  }

  Widget volumeBrightnessToast() {
    var volume = _volume;
    var brightness = _brightness;
    if (volume != null || brightness != null) {
      Widget toast = volume == null
          ? defaultFBrightnessToast(brightness!, _streamController.stream)
          : defaultFVolumeToast(volume, _streamController.stream);
      return IgnorePointer(
        child: AnimatedOpacity(
          opacity: 1,
          duration: const Duration(milliseconds: 500),
          child: toast,
        ),
      );
    }
    return Container();
  }

  Widget buildLongPressSpeedToast() {
    return Offstage(
      offstage: !longPress,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text(
          "Playing in 2x speed",
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget rightPositioned(bool visible, Widget child) {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Builder(
        builder: (_) {
          return CustomSwipeTransition(
            visible: visible,
            axis: Axis.horizontal,
            axisAlignment: 1.0,
            child: Container(
              color: const Color.fromRGBO(16, 17, 18, 1.0),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _playerLock(bool canScale, overlayVisible) {
    final controller = _query.video(context);
    final bool isFullScreen = controller.isFullScreen;
    final metadata = _query.videoMetadata(context);
    final style = _query.videoStyle(context);
    return Stack(
      children: [
        Positioned.fill(
          child: ValueListenableBuilder(
            valueListenable: _scale,
            builder: (_, double scale, __) => Transform.scale(
              scale: scale,
              child: FittedBox(
                clipBehavior: Clip.hardEdge,
                fit: controller.currentAspect,
                child: SizedBox(
                  width: controller.video!.value.size.width != 0
                      ? controller.video!.value.size.width
                      : 640,
                  height: controller.video!.value.size.height != 0
                      ? controller.video!.value.size.height
                      : 480,
                  child: const VideoCorePlayer(),
                ),
              ),
            ),
          ),
        ),
        const VideoCoreActiveSubtitleText(),
        GestureDetector(
          onTap: () => _query.video(context).showAndHideOverlay(),
          behavior: HitTestBehavior.opaque,
          child: const SizedBox(
            height: double.infinity,
            width: double.infinity,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
                left: isFullScreen ? 30 : 10,
                right: isFullScreen ? 30 : 10,
                bottom: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomOpacityTransition(
                    visible: !overlayVisible && showSkipStartButton,
                    child: GestureDetector(
                        onTap: () {
                          controller.seekTo(metadata.opEnd);
                          setState(() {
                            showSkipStartButton = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: isFullScreen ? 16 : 10,
                              vertical: isFullScreen ? 10 : 5),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(0, 202, 19, 1.0),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            "Skip OP",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isFullScreen ? 16 : 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))),
                CustomOpacityTransition(
                    visible: !overlayVisible && showSkipEndButton,
                    child: GestureDetector(
                        onTap: () {
                          controller.seekTo(metadata.edEnd);
                          setState(() {
                            showSkipEndButton = false;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: isFullScreen ? 16 : 10,
                              vertical: isFullScreen ? 10 : 5),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(0, 202, 19, 1.0),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            "Skip END",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isFullScreen ? 16 : 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _query.video(context).showAndHideOverlay(),
          behavior: HitTestBehavior.opaque,
          child: CustomOpacityTransition(
            visible: overlayVisible,
            child: Container(
              height: double.infinity,
              width: double.infinity,
              color: Colors.black.withValues(alpha: 0.6),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SplashCircularIcon(
                      padding: EdgeInsets.only(
                        left: isFullScreen ? 80 : 20,
                      ),
                      onTap: () => controller.openLock(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.3),
                          // borderRadius: BorderRadius.circular(7),
                        ),
                        child: controller.isLock
                            ? style.lock.locked
                            : style.lock.lock,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: isFullScreen
                        ? SizedBox(
                            height: 14,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              child: Row(
                                children: [
                                  const Spacer(),
                                  buildTimeNow(),
                                  const Spacer(),
                                  buildPower(),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ),
        const VideoCoreThumbnail(),
        const VideoCoreAdViewer(),
      ],
    );
  }

  Widget buildTimeNow() {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(left: 50),
      child: Text(
        '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  /// battery status in top right corner
  Widget buildPower() {
    if (batteryState == BatteryState.charging) {
      return Row(
        children: [
          Text(
            '$batteryLevel%',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          const Icon(Iconsax.battery_charging, color: Colors.green, size: 16),
        ],
      );
    } else {
      return Row(
        children: [
          Text(
            '$batteryLevel%',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          if (batteryLevel < 14)
            const Icon(
              Icons.battery_1_bar_rounded,
              color: Colors.white,
              size: 16,
            )
          else if (batteryLevel < 28)
            const Icon(
              Icons.battery_2_bar_rounded,
              color: Colors.white,
              size: 16,
            )
          else if (batteryLevel < 42)
            const Icon(
              Icons.battery_3_bar_rounded,
              color: Colors.white,
              size: 16,
            )
          else if (batteryLevel < 56)
            const Icon(
              Icons.battery_4_bar_rounded,
              color: Colors.white,
              size: 16,
            )
          else if (batteryLevel < 70)
            const Icon(
              Icons.battery_5_bar_rounded,
              color: Colors.white,
              size: 16,
            )
          else if (batteryLevel < 84)
            const Icon(
              Icons.battery_6_bar_rounded,
              color: Colors.white,
              size: 16,
            )
          else
            const Icon(
              Icons.battery_full_rounded,
              color: Colors.white,
              size: 16,
            ),
        ],
      );
    }
  }
}
