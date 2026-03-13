import 'dart:async';

import 'package:flutter/material.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/services.dart';

import 'package:video_player/video_player.dart';
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
import 'package:kenji_player/src/ui/settings_menu/widgets/speed_menu.dart';
import 'package:kenji_player/src/ui/settings_menu/widgets/aspect_menu.dart';
import 'package:kenji_player/src/ui/settings_menu/widgets/caption_menu.dart';
import 'package:kenji_player/src/ui/settings_menu/widgets/quality_menu.dart';
import 'package:kenji_player/src/ui/settings_menu/widgets/episode_menu.dart';

const Color _kSkipButtonColor = Color.fromRGBO(0, 202, 19, 1.0);
const Color _kPanelBgColor = Color.fromRGBO(16, 17, 18, 1.0);
const Duration _kDoubleTapHideDuration = Duration(milliseconds: 600);
const Duration _kBatteryRefreshInterval = Duration(seconds: 5);
const double _kMinScale = 1.0;
const double _kMaxScale = 3.0;

class KenjiPlayerCore extends StatefulWidget {
  const KenjiPlayerCore({super.key});

  @override
  KenjiPlayerCoreState createState() => KenjiPlayerCoreState();
}

class KenjiPlayerCoreState extends State<KenjiPlayerCore> {
  final VideoQuery _query = VideoQuery();

  bool _dragLeft = false;
  double? _volume;
  double? _brightness;
  final StreamController<double> _streamController =
      StreamController<double>.broadcast();

  bool _longPress = false;
  double _savedPlaybackSpeed = 1.0;

  bool _showSkipStartButton = false;
  bool _showSkipEndButton = false;

  VoidCallback? _positionListenerCallback;
  VideoPlayerController? _lastVideoController;

  KenjiPlayerController? _kenjiController;
  VoidCallback? _kenjiControllerListener;

  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  final ValueNotifier<int> _batteryLevel = ValueNotifier<int>(0);
  final ValueNotifier<BatteryState?> _batteryState =
      ValueNotifier<BatteryState?>(null);
  late Timer _batteryTimer;

  final ValueNotifier<int> _forwardAndRewindSecondsAmount =
      ValueNotifier<int>(1);
  int rewindDoubleTapCount = 0;
  int forwardDoubleTapCount = 0;
  int _defaultRewindAmount = -10;
  int _defaultForwardAmount = 10;
  Timer? _rewindDoubleTapTimer;
  Timer? _forwardDoubleTapTimer;
  final List<bool> _showRewindIcons = [false, false];

  final ValueNotifier<double> _currentVolume = ValueNotifier<double>(1.0);
  Timer? _closeVolumeStatus;

  final ValueNotifier<double> _scale = ValueNotifier<double>(1.0);
  double _baseScale = 1.0;

  @override
  void initState() {
    super.initState();

    Misc.onLayoutRendered(() async {
      if (!mounted) return;
      final metadata = _query.videoMetadata(context);
      _defaultRewindAmount = metadata.rewindAmount;
      _defaultForwardAmount = metadata.forwardAmount;

      VolumeController.instance.addListener((volume) {
        if (mounted) _currentVolume.value = volume;
      });

      _kenjiController = _query.video(context);
      _kenjiControllerListener = _onKenjiControllerChanged;
      _kenjiController!.addListener(_kenjiControllerListener!);

      _setupPositionListener();
      if (mounted) setState(() {});
    });

    _batteryStateSubscription =
        _battery.onBatteryStateChanged.listen((BatteryState state) {
      _batteryState.value = state;
    });

    _getBatteryLevel();
    _batteryTimer =
        Timer.periodic(_kBatteryRefreshInterval, (_) => _getBatteryLevel());
  }

  void _onKenjiControllerChanged() {
    if (!mounted) return;
    final newVideo = _kenjiController?.video;
    if (newVideo != _lastVideoController) {
      _setupPositionListener();
    }
  }

  void _setupPositionListener() {
    if (!mounted) return;
    final controller = _query.video(context);
    final newVideo = controller.video;

    if (_positionListenerCallback != null && _lastVideoController != null) {
      _lastVideoController!.removeListener(_positionListenerCallback!);
    }

    _positionListenerCallback = _checkSkipButtons;
    _lastVideoController = newVideo;
    newVideo?.addListener(_positionListenerCallback!);
  }

  void _checkSkipButtons() {
    if (!mounted) return;
    final controller = _query.video(context);
    final metadata = _query.videoMetadata(context);
    final Duration position = controller.position;

    final bool shouldShowOp = metadata.opStart != Duration.zero &&
        metadata.opEnd != Duration.zero &&
        position >= metadata.opStart &&
        position < metadata.opEnd;

    final bool shouldShowEd = metadata.edStart != Duration.zero &&
        metadata.edEnd != Duration.zero &&
        position >= metadata.edStart &&
        position < metadata.edEnd;

    if (_showSkipStartButton != shouldShowOp ||
        _showSkipEndButton != shouldShowEd) {
      setState(() {
        _showSkipStartButton = shouldShowOp;
        _showSkipEndButton = shouldShowEd;
      });
    }
  }

  @override
  void dispose() {
    if (_positionListenerCallback != null && _lastVideoController != null) {
      _lastVideoController!.removeListener(_positionListenerCallback!);
    }
    if (_kenjiControllerListener != null && _kenjiController != null) {
      _kenjiController!.removeListener(_kenjiControllerListener!);
    }

    _batteryTimer.cancel();
    _batteryStateSubscription?.cancel();
    _streamController.close();
    VolumeController.instance.removeListener();
    _scale.dispose();
    _currentVolume.dispose();
    _batteryLevel.dispose();
    _batteryState.dispose();
    _forwardAndRewindSecondsAmount.dispose();
    _closeVolumeStatus?.cancel();
    _rewindDoubleTapTimer?.cancel();
    _forwardDoubleTapTimer?.cancel();
    super.dispose();
  }

  Future<void> _getBatteryLevel() async {
    final int level = await _battery.batteryLevel;
    _batteryLevel.value = level;
  }

  double _panelHeight() => MediaQuery.of(context).size.height;
  double _panelWidth() => MediaQuery.of(context).size.width;

  bool _canDrag() {
    final controller = _query.video(context);
    return !(controller.isDraggingProgressBar ||
        controller.activeAd != null ||
        controller.isShowingEpisode);
  }

  void onBrightnessStartFun(DragStartDetails d) {
    if (!_canDrag()) return;
    final metadata = _query.videoMetadata(context);
    final double dy = d.localPosition.dy;
    final double dx = d.localPosition.dx;
    if (dy <= 40 || dy >= _panelHeight() - 40) return;
    final bool useVolume = metadata.volume;
    final bool useBrightness = metadata.brightness;
    final bool isRight = dx > _panelWidth() / 2;
    _dragLeft = !isRight;
    if (useVolume && (!useBrightness || isRight)) {
      VolumeController.instance.getVolume().then((v) {
        if (mounted) setState(() => _volume = v);
      });
    } else if (useBrightness && (useVolume || !isRight)) {
      ScreenBrightness().application.then((v) {
        if (mounted) {
          setState(() => _brightness = v);
          _streamController.add(v);
        }
      });
    }
  }

  void onBrightnessUpdateFun(DragUpdateDetails d) {
    if (!_canDrag()) return;
    final metadata = _query.videoMetadata(context);
    final bool isFullScreen = _query.video(context).isFullScreen;
    double delta = d.primaryDelta! / _panelHeight();
    if (!isFullScreen) delta *= 2;
    delta = -delta.clamp(-1.0, 1.0);
    if (!_dragLeft && metadata.volume) {
      _adjustVolume(delta);
    } else if (_dragLeft && metadata.brightness) {
      _adjustBrightness(delta);
    }
  }

  void _adjustVolume(double delta) {
    var volume = _volume;
    if (volume == null) return;
    volume = (volume + delta).clamp(0.0, 1.0);
    _volume = volume;
    VolumeController.instance.showSystemUI = false;
    VolumeController.instance.setVolume(volume);
    setState(() => _streamController.add(volume!));
  }

  void _adjustBrightness(double delta) {
    var brightness = _brightness;
    if (brightness == null) return;
    brightness = (brightness + delta).clamp(0.0, 1.0);
    _brightness = brightness;
    ScreenBrightness().setApplicationScreenBrightness(brightness);
    setState(() => _streamController.add(brightness!));
  }

  void onBrightnessEndFun(DragEndDetails _) {
    setState(() {
      _volume = null;
      _brightness = null;
    });
  }

  void _rewind() => _showRewindAndForward(0, _defaultRewindAmount);
  void _forward() => _showRewindAndForward(1, _defaultForwardAmount);

  Future<void> _seekBySeconds(int seconds) async {
    final controller = _query.video(context);
    final int pos = controller.video!.value.position.inSeconds;
    await controller.seekTo(Duration(seconds: pos + seconds));
    await controller.play();
  }

  void _showRewindAndForward(int index, int amount) {
    _seekBySeconds(amount);
    if (!_canDrag()) return;
    if (index == 0) {
      if (!_showRewindIcons[0]) rewindDoubleTapCount = 0;
      _rewindDoubleTapTimer?.cancel();
      rewindDoubleTapCount++;
      _rewindDoubleTapTimer = Misc.timer(
        _kDoubleTapHideDuration.inMilliseconds,
        () {
          if (mounted) setState(() => _showRewindIcons[0] = false);
        },
      );
    } else {
      if (!_showRewindIcons[1]) forwardDoubleTapCount = 0;
      _forwardDoubleTapTimer?.cancel();
      forwardDoubleTapCount++;
      _forwardDoubleTapTimer = Misc.timer(
        _kDoubleTapHideDuration.inMilliseconds,
        () {
          if (mounted) setState(() => _showRewindIcons[1] = false);
        },
      );
    }
    setState(() => _showRewindIcons[index] = true);
  }

  void _onLongPress() {
    final controller = _query.video(context);
    if (!controller.isPlaying) return;
    HapticFeedback.lightImpact();
    _savedPlaybackSpeed = controller.video!.value.playbackSpeed;
    setState(() {
      _longPress = true;
      controller.video!.setPlaybackSpeed(2.0);
    });
  }

  void _onLongPressUp() {
    final controller = _query.video(context);
    setState(() {
      controller.video!.setPlaybackSpeed(_savedPlaybackSpeed);
      _longPress = false;
    });
  }

  void _onScaleStart(ScaleStartDetails d) {
    _baseScale = _scale.value;
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (d.pointerCount < 2) return;
    _scale.value = (_baseScale * d.scale).clamp(_kMinScale, _kMaxScale);
  }

  void _onScaleEnd(ScaleEndDetails d) {
    if (_scale.value < 1.05) _scale.value = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _query.video(context, listen: true);
    final bool isLock = controller.isLock;
    final bool overlayVisible = controller.isShowingOverlay;

    return VideoCoreOrientation(
      builder: (isFullScreenLandscape) {
        if (controller.hasError) {
          return _buildErrorWidget(controller, isFullScreenLandscape);
        }

        if (controller.isAdLoaded && !controller.shouldShowContentVideo) {
          return KeyedSubtree(
            key: const ValueKey('ad_container'),
            child: controller.adDisplayContainer,
          );
        }

        final Widget player = isLock
            ? _playerLock(isFullScreenLandscape, overlayVisible)
            : _global(isFullScreenLandscape, overlayVisible);

        return VideoCoreAspectRadio(child: player);
      },
    );
  }

  Widget _buildErrorWidget(
      KenjiPlayerController controller, bool isFullScreen) {
    final Widget content = Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 48),
            const SizedBox(height: 12),
            const Text('Failed to load the video',
                style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              controller.errorState?.message ?? '',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
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
              onPressed: () => controller.retryCurrentSource(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
    return isFullScreen ? content : VideoCoreAspectRadio(child: content);
  }

  Widget _global(bool isFullScreenLandscape, bool overlayVisible) {
    final controller = _query.video(context);
    return Stack(
      children: [
        _globalGesture(isFullScreenLandscape, overlayVisible),
        rightPositioned(controller.isShowingSpeed, const SpeedMenu()),
        rightPositioned(controller.isShowingAspect, const AspectMenu()),
        rightPositioned(controller.isShowingCaption, const CaptionMenu()),
        rightPositioned(controller.isShowingQuality, const QualityMenu()),
        rightPositioned(controller.isShowingEpisode, const EpisodeMenu()),
      ],
    );
  }

  Widget _globalGesture(bool canScale, bool overlayVisible) {
    final controller = _query.video(context);
    final bool isFullScreen = controller.isFullScreen;
    return GestureDetector(
      onLongPress: controller.isPlaying ? _onLongPress : null,
      onLongPressUp: controller.isPlaying ? _onLongPressUp : null,
      onVerticalDragStart: isFullScreen ? onBrightnessStartFun : null,
      onVerticalDragUpdate: isFullScreen ? onBrightnessUpdateFun : null,
      onVerticalDragEnd: isFullScreen ? onBrightnessEndFun : null,
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      child: _player(overlayVisible),
    );
  }

  Widget _player(bool overlayVisible) {
    final controller = _query.video(context, listen: true);
    final bool isFullScreen = controller.isFullScreen;
    final style = _query.videoStyle(context);
    final metadata = _query.videoMetadata(context);

    return Stack(
      children: [
        Positioned.fill(
          child: ValueListenableBuilder<double>(
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
          child: const SizedBox.expand(),
        ),
        GestureDetector(
          onTap: () => _query.video(context).showAndHideOverlay(),
          behavior: HitTestBehavior.opaque,
          child: CustomOpacityTransition(
            visible: overlayVisible,
            child: Container(
              color: Colors.black.withValues(alpha: 0.6),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        VideoCoreForwardAndRewindLayout(
          rewind: GestureDetector(onDoubleTap: _rewind),
          forward: GestureDetector(onDoubleTap: _forward),
        ),
        Builder(builder: (_) {
          final c = _query.video(context, listen: true);
          return CustomOpacityTransition(
            visible: (c.position >= c.duration && !c.isShowingOverlay) ||
                _showRewindIcons[0] ||
                _showRewindIcons[1] ||
                c.isChangingSource ||
                c.isBuffering,
            child: Center(
              child: CenterPlayAndPause(
                type: CenterPlayAndPauseType.center,
                showRewind: _showRewindIcons[0],
                showForward: _showRewindIcons[1],
              ),
            ),
          );
        }),
        VideoCoreOverlay(
          showRewind: _showRewindIcons[0],
          showForward: _showRewindIcons[1],
          showSkipStartButton: _showSkipStartButton,
          showSkipEndButton: _showSkipEndButton,
          startButton: () {
            _query.video(context).seekTo(metadata.opEnd);
            setState(() => _showSkipStartButton = false);
          },
          endButton: () {
            _query.video(context).seekTo(metadata.edEnd);
            setState(() => _showSkipEndButton = false);
          },
          child: isFullScreen ? _statusBar() : const SizedBox.shrink(),
        ),
        if (metadata.lock)
          CustomOpacityTransition(
            visible: overlayVisible,
            child: Align(
              alignment: Alignment.centerLeft,
              child: SplashCircularIcon(
                padding: EdgeInsets.only(left: isFullScreen ? 80 : 20),
                onTap: () => controller.openLock(),
                child: _lockIcon(controller, style),
              ),
            ),
          ),
        Align(
          alignment: Alignment.topCenter,
          child: _buildLongPressSpeedToast(),
        ),
        _volumeBrightnessToast(),
        const VideoCoreThumbnail(),
        const VideoCoreAdViewer(),
      ],
    );
  }

  Widget _playerLock(bool canScale, bool overlayVisible) {
    final controller = _query.video(context);
    final bool isFullScreen = controller.isFullScreen;
    final metadata = _query.videoMetadata(context);
    final style = _query.videoStyle(context);

    return Stack(
      children: [
        Positioned.fill(
          child: ValueListenableBuilder<double>(
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
          child: const SizedBox.expand(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              left: isFullScreen ? 30 : 10,
              right: isFullScreen ? 30 : 10,
              bottom: 100,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomOpacityTransition(
                  visible: !overlayVisible && _showSkipStartButton,
                  child: _skipButton(
                    label: 'Skip OP',
                    isFullScreen: isFullScreen,
                    onTap: () {
                      controller.seekTo(metadata.opEnd);
                      setState(() => _showSkipStartButton = false);
                    },
                  ),
                ),
                CustomOpacityTransition(
                  visible: !overlayVisible && _showSkipEndButton,
                  child: _skipButton(
                    label: 'Skip END',
                    isFullScreen: isFullScreen,
                    onTap: () {
                      controller.seekTo(metadata.edEnd);
                      setState(() => _showSkipEndButton = false);
                    },
                  ),
                ),
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
              color: Colors.black.withValues(alpha: 0.6),
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SplashCircularIcon(
                      padding: EdgeInsets.only(left: isFullScreen ? 80 : 20),
                      onTap: () => controller.openLock(),
                      child: _lockIcon(controller, style),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child:
                        isFullScreen ? _statusBar() : const SizedBox.shrink(),
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

  Widget _skipButton({
    required String label,
    required bool isFullScreen,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isFullScreen ? 16 : 10,
          vertical: isFullScreen ? 10 : 5,
        ),
        decoration: BoxDecoration(
          color: _kSkipButtonColor,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: isFullScreen ? 16 : 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _lockIcon(KenjiPlayerController controller, dynamic style) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.3),
      ),
      child: controller.isLock ? style.lock.locked : style.lock.lock,
    );
  }

  Widget _statusBar() {
    return SizedBox(
      height: 14,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          children: [
            const Spacer(),
            _buildTimeNow(),
            const Spacer(),
            ValueListenableBuilder<int>(
              valueListenable: _batteryLevel,
              builder: (_, int level, __) =>
                  ValueListenableBuilder<BatteryState?>(
                valueListenable: _batteryState,
                builder: (_, BatteryState? state, __) =>
                    _buildPower(level, state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rightPositioned(bool visible, Widget child) {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: CustomSwipeTransition(
        visible: visible,
        axis: Axis.horizontal,
        axisAlignment: 0.2,
        child: Container(color: _kPanelBgColor, child: child),
      ),
    );
  }

  Widget _volumeBrightnessToast() {
    final double? volume = _volume;
    final double? brightness = _brightness;
    if (volume == null && brightness == null) return const SizedBox.shrink();
    final Widget toast = volume == null
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

  Widget _buildLongPressSpeedToast() {
    return Offstage(
      offstage: !_longPress,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text('Playing in 2x speed',
            style: TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }

  Widget _buildTimeNow() {
    final now = DateTime.now();
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(left: 50),
      child: Text(
        '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
        style: const TextStyle(
            fontWeight: FontWeight.w500, color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget _buildPower(int level, BatteryState? state) {
    final bool charging = state == BatteryState.charging;
    return Row(
      children: [
        Text('$level%',
            style: const TextStyle(color: Colors.white, fontSize: 10)),
        Icon(
          charging ? PhosphorIcons.batteryCharging() : _batteryIcon(level),
          color: charging ? Colors.green : Colors.white,
          size: 16,
        ),
      ],
    );
  }

  IconData _batteryIcon(int level) {
    if (level <= 14) return PhosphorIcons.batteryEmpty();
    if (level <= 34) return PhosphorIcons.batteryLow();
    if (level <= 54) return PhosphorIcons.batteryMedium();
    if (level <= 79) return PhosphorIcons.batteryHigh();
    return PhosphorIcons.batteryFull();
  }
}
