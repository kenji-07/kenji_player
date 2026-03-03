import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:interactive_media_ads/interactive_media_ads.dart';

import 'package:kenji_player/src/ui/fullscreen.dart';
import 'package:kenji_player/src/misc.dart';
import 'package:kenji_player/src/domain/entities/ads.dart';
import 'package:kenji_player/src/data/repositories/video.dart';
import 'package:kenji_player/src/domain/entities/subtitle.dart';
import 'package:kenji_player/src/domain/entities/video_source.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:kenji_player/src/ui/widgets/helpers.dart';

const int _kMillisecondsToHideTheOverlay = 2800;

enum _PanelType { caption, quality, speed, episode, aspect, settings }

class VideoErrorState {
  const VideoErrorState({required this.message, required this.sourceName});
  final String message;
  final String sourceName;
}

class KenjiPlayerController extends ChangeNotifier with WidgetsBindingObserver {
  final List<KenjiPlayerAd> adsSeen = [];

  static const String _aspectKey = 'currentAspect';
  static const String _subtitleSizeKey = 'currentSubtitleSize';

  BoxFit _currentAspect = BoxFit.cover;
  int _currentSubtitleSize = 23;

  AdsLoader? adsLoader;
  Timer? _contentProgressTimer;
  final ContentProgressProvider _contentProgressProvider =
      ContentProgressProvider();
  bool isAdLoaded = false;
  String? _imaAdTagUrl;
  AdsManager? _adsManager;

  KenjiPlayerAd? _activeAd;
  Timer? _activeAdTimeRemaining;
  Duration? _adTimeWatched;
  List<KenjiPlayerAd>? _ads;

  String? _activeSourceName;
  String? _activeSubtitle;
  SubtitleData? _activeSubtitleData;
  KenjiPlayerSubtitle? _subtitle;
  Map<String, VideoSource>? _source;
  VideoPlayerController? _video;

  late bool looping;
  bool _mounted = false;
  bool _isBuffering = false;
  bool _isShowingOverlay = true;
  bool _isFullScreen = false;
  bool _isLock = false;
  bool _isShowingThumbnail = true;
  bool _isDraggingProgressBar = false;
  bool _isChangingSource = false;
  bool _shouldShowContentVideo = false;
  bool _videoWasPlaying = false;

  // ───  Error state ───────────────────────────────────────────────────────
  VideoErrorState? _errorState;
  VideoErrorState? get errorState => _errorState;
  bool get hasError => _errorState != null;

  // ─── Adaptive bitrate ─────────────────────────────────────────────────
  /// Буферын хувийг хянах (0.0 ~ 1.0)
  double _bufferHealthRatio = 1.0;
  double get bufferHealthRatio => _bufferHealthRatio;
  Timer? _adaptiveTimer;

  /// Доод буферын босго (10 секунд)
  static const Duration _kLowBufferThreshold = Duration(seconds: 0);

  /// Сайн буферын босго (30 секунд)
  static const Duration _kGoodBufferThreshold = Duration(seconds: 30);

  bool _isShowingEpisode = false;
  bool _isShowingSettings = false;
  bool _isShowingCaption = false;
  bool _isShowingQuality = false;
  bool _isShowingSpeed = false;
  bool _isShowingAspect = false;

  bool _isGoingToCloseOverlay = false;
  bool _isGoingToOpenOrCloseFullscreen = false;
  bool _isGoingToOpenOrLocked = false;
  bool _isGoingToOpenOrChat = false;
  bool _isGoingToOpenOrCaption = false;
  bool _isGoingToOpenOrQuality = false;
  bool _isGoingToOpenOrSpeed = false;
  bool _isGoingToOpenOrAspect = false;

  BuildContext? context;
  Duration _maxBuffering = Duration.zero;
  Timer? _closeOverlayButtons;

  // ─── Getters ──────────────────────────────────────────────────────────────

  Duration get beginRange {
    if (_video == null) return Duration.zero;
    final Duration duration = _video!.value.duration;
    final Tween<Duration>? range = activeSource?.range;
    Duration begin = range?.begin ?? Duration.zero;
    if (begin >= duration) begin = Duration.zero;
    return begin;
  }

  Duration get endRange {
    if (_video == null) return Duration.zero;
    final Duration duration = _video!.value.duration;
    final Tween<Duration>? range = activeSource?.range;
    Duration end = range?.end ?? duration;
    if (end >= duration) end = duration;
    return end;
  }

  Duration get position {
    if (_video == null) return Duration.zero;
    final pos = _video!.value.position - beginRange;
    return pos < Duration.zero ? Duration.zero : pos;
  }

  Duration _duration = Duration.zero;

  bool get mounted => _mounted;
  Duration get duration => _duration;
  VideoSource? get activeSource => _source?[_activeSourceName];
  KenjiPlayerAd? get activeAd => _activeAd;
  Duration? get adTimeWatched => _adTimeWatched;
  VideoPlayerController? get video => _video;
  SubtitleData? get activeCaptionData => _activeSubtitleData;
  List<SubtitleData>? get subtitles => _subtitle?.subtitles;
  KenjiPlayerSubtitle? get subtitle => _subtitle;
  String? get activeCaption => _activeSubtitle;
  String? get activeSourceName => _activeSourceName;
  Duration get maxBuffering => _maxBuffering;
  bool get isShowingOverlay => _isShowingOverlay;
  bool get isFullScreen => _isFullScreen;
  bool get isLock => _isLock;
  bool get isPlaying => _video?.value.isPlaying ?? false;
  bool get isShowingEpisode => _isShowingEpisode;
  bool get isShowingSpeed => _isShowingSpeed;
  bool get isShowingAspect => _isShowingAspect;
  bool get isShowingSettings => _isShowingSettings;
  bool get isShowingCaption => _isShowingCaption;
  bool get isShowingQuality => _isShowingQuality;
  bool get isChangingSource => _isChangingSource;
  BoxFit get currentAspect => _currentAspect;
  int get currentSubtitleSize => _currentSubtitleSize;
  bool get shouldShowContentVideo => _shouldShowContentVideo;
  Map<String, VideoSource>? get source => _source;

  // ─── Setters ──────────────────────────────────────────────────────────────

  set source(Map<String, VideoSource>? value) {
    _source = value;
    notifyListeners();
  }

  set isShowingSettings(bool v) {
    _isShowingSettings = v;
    notifyListeners();
  }

  set isShowingCaption(bool v) {
    _isShowingCaption = v;
    notifyListeners();
  }

  set isShowingQuality(bool v) {
    _isShowingQuality = v;
    notifyListeners();
  }

  set isShowingEpisode(bool v) {
    _isShowingEpisode = v;
    notifyListeners();
  }

  set isShowingSpeed(bool v) {
    _isShowingSpeed = v;
    notifyListeners();
  }

  set isShowingAspect(bool v) {
    _isShowingAspect = v;
    notifyListeners();
  }

  set isBuffering(bool value) {
    _isBuffering = value;
    notifyListeners();
  }

  set isShowingThumbnail(bool value) {
    _isShowingThumbnail = value;
    notifyListeners();
  }

  set isDraggingProgressBar(bool value) {
    _isDraggingProgressBar = value;
    notifyListeners();
  }

  bool get isBuffering => _isBuffering;
  bool get isShowingThumbnail => _isShowingThumbnail;
  bool get isDraggingProgressBar => _isDraggingProgressBar;

  @override
  void notifyListeners() {
    if (_mounted) super.notifyListeners();
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  Future<void> initialize(
    Map<String, VideoSource> sources, {
    bool autoPlay = true,
    Duration? seekTo,
  }) async {
    WidgetsBinding.instance.addObserver(this);
    _mounted = true;
    _source = sources;

    final MapEntry<String, VideoSource> entry = sources.entries.first;
    await changeSource(
      name: entry.key,
      source: entry.value,
      autoPlay: autoPlay,
    );

    if (seekTo != null) await _video?.seekTo(seekTo);
    _loadPlayerSettingsFromStorage();
    debugPrint('VIDEO PLAYER INITIALIZED');
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _mounted = false;
    isAdLoaded = false;
    _closeOverlayButtons?.cancel();
    _adaptiveTimer?.cancel();
    _deleteAdTimer();
    _video?.removeListener(_videoListener);
    await _video?.pause();
    await _video?.dispose();
    _contentProgressTimer?.cancel();
    _adsManager?.destroy();
    try {
      adsLoader?.contentComplete();
    } catch (e) {
      debugPrint('AdsLoader not initialized: $e');
    }
    debugPrint('VIDEO PLAYER DISPOSED');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        if (!_shouldShowContentVideo) _adsManager?.resume();
        _videoWasPlaying = isPlaying;
        if (_videoWasPlaying) pause();
        break;
      case AppLifecycleState.resumed:
        if (_videoWasPlaying) play();
        break;
      case AppLifecycleState.inactive:
        if (!_shouldShowContentVideo) _adsManager?.pause();
        break;
      default:
        break;
    }
  }

  // ─── IMA ──────────────────────────────────────────────────────────────────

  void setImaAdTagUrl(String url) => _imaAdTagUrl = url;

  Future<void> setAdLoadingState(bool value) async {
    isAdLoaded = value;
    notifyListeners();
  }

  Future<void> _requestAds(AdDisplayContainer container) {
    if (_imaAdTagUrl == null) return Future.value();
    return adsLoader?.requestAds(AdsRequest(
          adTagUrl: _imaAdTagUrl!,
          contentProgressProvider: _contentProgressProvider,
        )) ??
        Future.value();
  }

  Future<void> _resumeContent() async {
    _shouldShowContentVideo = true;
    notifyListeners();
    if (_adsManager != null) {
      _contentProgressTimer = Timer.periodic(
        const Duration(milliseconds: 200),
        (timer) async {
          if (_video?.value.isInitialized ?? false) {
            final Duration? progress = _video?.value.position;
            if (progress != null) {
              await _contentProgressProvider.setProgress(
                progress: progress,
                duration: _video!.value.duration,
              );
            }
          }
        },
      );
    }
    await _video?.play();
  }

  Future<void> _pauseContent() async {
    _shouldShowContentVideo = false;
    notifyListeners();
    _contentProgressTimer?.cancel();
    _contentProgressTimer = null;
    await _video?.pause();
  }

  late final AdDisplayContainer adDisplayContainer = AdDisplayContainer(
    onContainerAdded: (AdDisplayContainer container) {
      if (!isAdLoaded) {
        _resumeContent();
        return;
      }
      _video?.pause();
      adsLoader = AdsLoader(
        container: container,
        onAdsLoaded: (OnAdsLoadedData data) {
          _adsManager = data.manager;
          _adsManager!.setAdsManagerDelegate(AdsManagerDelegate(
            onAdEvent: (AdEvent event) {
              switch (event.type) {
                case AdEventType.loaded:
                  setAdLoadingState(true);
                  _adsManager!.start();
                  break;
                case AdEventType.contentPauseRequested:
                  _pauseContent();
                  break;
                case AdEventType.contentResumeRequested:
                  setAdLoadingState(false);
                  _resumeContent();
                  break;
                case AdEventType.allAdsCompleted:
                  _adsManager!.destroy();
                  _adsManager = null;
                  setAdLoadingState(false);
                  break;
                default:
                  break;
              }
            },
            onAdErrorEvent: (AdErrorEvent event) {
              debugPrint('IMA Error: ${event.error.message}');
              setAdLoadingState(false);
              _resumeContent();
            },
          ));
          _adsManager!.init(settings: AdsRenderingSettings());
        },
        onAdsLoadError: (AdsLoadErrorData data) {
          _adsManager = null;
          setAdLoadingState(false);
          _resumeContent();
        },
      );
      _requestAds(container);
    },
  );

  // ─── Source control ───────────────────────────────────────────────────────

  Future<void> changeSource({
    required VideoSource source,
    required String name,
    bool inheritPosition = true,
    bool autoPlay = true,
  }) async {
    if (_activeSourceName == name && _video != null) return;

    _errorState = null;

    final double speed = _video?.value.playbackSpeed ?? 1.0;
    final double volume = _video?.value.volume ?? 1.0;
    final Duration lastPosition = _video?.value.position ?? Duration.zero;

    if (source.subtitle != null) {
      final sub = source.subtitle![source.intialSubtitle];
      if (sub != null)
        changeSubtitle(subtitle: sub, subtitleName: source.intialSubtitle);
    }

    _ads = source.ads?.where((ad) => !adsSeen.contains(ad)).toList();

    final VideoPlayerController? oldVideo = _video;
    if (oldVideo != null) {
      _isChangingSource = true;
      await oldVideo.pause();
      notifyListeners();
    }

    try {
      final VideoPlayerController newVideo = source.video.value.isInitialized
          ? VideoPlayerController.networkUrl(
              Uri.parse(source.video.dataSource),
              httpHeaders: source.httpHeaders ?? {},
            )
          : source.video;

      await newVideo.initialize();

      if (oldVideo != null) {
        oldVideo.removeListener(_videoListener);
        await oldVideo.pause();
        await oldVideo.dispose();
      }

      _video = newVideo;
      _video!.addListener(_videoListener);
      _activeSourceName = name;
      _duration = endRange - beginRange;

      await _video!.setPlaybackSpeed(speed);
      await _video!.setLooping(looping);
      await _video!.setVolume(volume);

      if (inheritPosition) {
        if (lastPosition > Duration.zero &&
            lastPosition < _video!.value.duration) {
          await _video!.seekTo(lastPosition);
        } else if (source.range != null) {
          await _video!.seekTo(beginRange);
        }
      } else if (source.range != null) {
        await _video!.seekTo(beginRange);
      }

      _isChangingSource = false;

      // ─── Adaptive bitrate timer start ──────────────────────────
      _startAdaptiveBitrateMonitor();

      notifyListeners();
      if (autoPlay) await play();
    } catch (e) {
      debugPrint('Error changing source to $name: $e');
      _isChangingSource = false;

      // ─── Error state set ───────────────────────────────────────────
      _errorState = VideoErrorState(
        message: e.toString(),
        sourceName: name,
      );

      if (oldVideo != null && oldVideo.value.isInitialized) {
        _video = oldVideo;
        _video!.addListener(_videoListener);
      }
      notifyListeners();
    }
  }

  // ─── Retry ───────────────────────────
  Future<void> retryCurrentSource() async {
    final String? name = _errorState?.sourceName ?? _activeSourceName;
    if (name == null || _source == null) return;
    final VideoSource? source = _source![name];
    if (source == null) return;
    await changeSource(source: source, name: name, inheritPosition: false);
  }

  // ─── Adaptive bitrate monitor ─────────────────────────────────────────
  void _startAdaptiveBitrateMonitor() {
    _adaptiveTimer?.cancel();
    _adaptiveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkAndAdaptQuality();
    });
  }

  void _checkAndAdaptQuality() {
    if (_source == null || _source!.length <= 1) return;
    if (_video == null || !_video!.value.isInitialized) return;

    final Duration currentPos = _video!.value.position;
    final Duration bufferedEnd = _maxBuffering;
    final Duration bufferedAhead = bufferedEnd - currentPos;

    _bufferHealthRatio =
        (bufferedAhead.inMilliseconds / _kGoodBufferThreshold.inMilliseconds)
            .clamp(0.0, 1.0);

    // Буфер хэт бага болвол доод чанарт шилжинэ
    if (bufferedAhead < _kLowBufferThreshold && isPlaying) {
      _switchToLowerQuality();
    }
    notifyListeners();
  }

  void _switchToLowerQuality() {
    if (_source == null || _activeSourceName == null) return;
    final List<String> keys = _source!.keys.toList();
    final int currentIndex = keys.indexOf(_activeSourceName!);

    // "Auto" эсвэл хамгийн доод чанар биш бол доошлуулна
    if (currentIndex >= 0 && currentIndex < keys.length - 1) {
      final String lowerKey = keys[currentIndex + 1];
      final VideoSource? lowerSource = _source![lowerKey];
      if (lowerSource != null) {
        debugPrint(
            'Adaptive: switching ${_activeSourceName} → $lowerKey (low buffer)');
        changeSource(
            source: lowerSource, name: lowerKey, inheritPosition: true);
      }
    }
  }

  Future<void> changeSubtitle({
    required KenjiPlayerSubtitle? subtitle,
    required String subtitleName,
  }) async {
    _activeSubtitle = subtitleName;
    _activeSubtitleData = null;
    _subtitle = subtitle;
    if (subtitle != null) await subtitle.initialize();
    notifyListeners();
  }

  // ─── Video control ────────────────────────────────────────────────────────

  Future<void> playOrPause() async {
    _vibrateOnce();
    if (isPlaying) {
      await pause();
    } else {
      await _seekToBeginIfEnded();
      await play();
    }
  }

  Future<void> play() async {
    if (!_isChangingSource && _activeAd == null) {
      if (looping) await _seekToBeginIfEnded();
      await _video?.play();
    }
  }

  Future<void> pause() async {
    if (!_isChangingSource) await _video?.pause();
  }

  Future<void> _seekToBeginIfEnded() async {
    if (position >= duration) await seekTo(beginRange);
  }

  Future<void> seekTo(Duration pos) async {
    if (_isChangingSource) return;
    final Duration clampedPos = pos.clamp(beginRange, endRange);
    await _video?.seekTo(clampedPos);
  }

  // ─── Video listener ───────────────────────────────────────────────────────

  void _videoListener() {
    final VideoPlayerValue value = _video!.value;
    final Duration pos = value.position;
    final Duration dur = value.duration;
    final Tween<Duration>? range = activeSource?.range;

    if (range != null) {
      if (pos < beginRange || pos >= endRange) {
        if (looping) {
          _video?.seekTo(beginRange);
        } else if (isPlaying && pos >= endRange) {
          _video?.pause();
        }
      }
    }

    if (isPlaying && _isShowingThumbnail) {
      _isShowingThumbnail = false;
      notifyListeners();
    }

    if (_isBuffering != value.isBuffering && !_isDraggingProgressBar) {
      _isBuffering = value.isBuffering;
      notifyListeners();
    }

    Duration newMaxBuffering = Duration.zero;
    for (final DurationRange r in value.buffered) {
      if (r.end > newMaxBuffering) newMaxBuffering = r.end;
    }
    if (newMaxBuffering != _maxBuffering) {
      _maxBuffering = newMaxBuffering;
      notifyListeners();
    }

    if (_isShowingOverlay) {
      if (isPlaying) {
        if (pos >= dur && looping) {
          seekTo(Duration.zero);
        } else if (_closeOverlayButtons == null) {
          _startCloseOverlay();
        }
      } else if (_isGoingToCloseOverlay) {
        cancelCloseOverlay();
      }
    }

    if (_subtitle != null && subtitles != null) {
      if (_activeSubtitleData == null ||
          !(pos > _activeSubtitleData!.start &&
              pos < _activeSubtitleData!.end)) {
        _findSubtitle();
      }
    }

    if (_ads != null) {
      if (_activeAd == null ||
          !(pos > _getAdStartTime(_activeAd!) &&
              pos < _getAdStartTime(_activeAd!) + _activeAd!.durationToEnd)) {
        _findAd();
      }
    }
  }

  // ─── Ads ──────────────────────────────────────────────────────────────────

  Future<void> skipAd() async {
    _activeAd = null;
    _deleteAdTimer();
    await play();
    notifyListeners();
  }

  void _findAd() {
    final Duration pos = position;
    bool found = false;
    for (final KenjiPlayerAd ad in List.from(_ads!)) {
      final Duration start = _getAdStartTime(ad);
      if (pos > start && pos < start + ad.durationToEnd && _activeAd != ad) {
        _activeAd = ad;
        _video?.pause();
        _ads?.remove(ad);
        _createAdTimer();
        adsSeen.add(ad);
        found = true;
        notifyListeners();
        break;
      }
    }
    if (!found && _activeAd != null) {
      _activeAd = null;
      _deleteAdTimer();
      notifyListeners();
    }
  }

  Duration _getAdStartTime(KenjiPlayerAd ad) =>
      ad.durationToStart ?? duration * ad.fractionToStart!;

  void _createAdTimer() {
    const Duration refresh = Duration(milliseconds: 500);
    _activeAdTimeRemaining = Timer.periodic(refresh, (timer) {
      _adTimeWatched = (_adTimeWatched ?? Duration.zero) + refresh;
      if (_activeAd != null && _adTimeWatched! >= _activeAd!.durationToSkip) {
        timer.cancel();
      }
      notifyListeners();
    });
  }

  void _deleteAdTimer() {
    _activeAdTimeRemaining?.cancel();
    _activeAdTimeRemaining = null;
    _adTimeWatched = null;
  }

  // ─── Subtitle ─────────────────────────────────────────────────────────────

  void _findSubtitle() {
    final Duration pos = _video!.value.position;
    bool found = false;
    for (final SubtitleData sub in subtitles!) {
      if (pos > sub.start && pos < sub.end && _activeSubtitleData != sub) {
        _activeSubtitleData = sub;
        found = true;
        notifyListeners();
        break;
      }
    }
    if (!found && _activeSubtitleData != null) {
      _activeSubtitleData = null;
      notifyListeners();
    }
  }

  void setSubtitleSize(int size) {
    _currentSubtitleSize = size;
    Utils.setString(key: _subtitleSizeKey, value: size.toString());
    notifyListeners();
  }

  // ─── Overlay ──────────────────────────────────────────────────────────────

  void cancelCloseOverlay() {
    _isGoingToCloseOverlay = false;
    _closeOverlayButtons?.cancel();
    _closeOverlayButtons = null;
    notifyListeners();
  }

  void _startCloseOverlay() {
    if (!_isGoingToCloseOverlay) {
      _isGoingToCloseOverlay = true;
      _closeOverlayButtons = Misc.timer(_kMillisecondsToHideTheOverlay, () {
        if (isPlaying) {
          _isShowingOverlay = false;
          cancelCloseOverlay();
        }
      });
      notifyListeners();
    }
  }

  void showAndHideOverlay([bool? show]) {
    if (_anyPanelOpen) {
      _closeAllPanels();
    } else {
      _isShowingOverlay = show ?? !_isShowingOverlay;
      if (_isShowingOverlay) cancelCloseOverlay();
      notifyListeners();
    }
  }

  bool get _anyPanelOpen =>
      _isShowingEpisode ||
      _isShowingSpeed ||
      _isShowingAspect ||
      _isShowingCaption ||
      _isShowingQuality ||
      _isShowingSettings;

  void _closeAllPanels() {
    _isShowingEpisode = false;
    _isShowingSpeed = false;
    _isShowingAspect = false;
    _isShowingCaption = false;
    _isShowingQuality = false;
    _isShowingSettings = false;
    notifyListeners();
  }

  // ─── Panel toggle ─────────────────────────────────────────────────────────

  void _togglePanel(_PanelType type) {
    final bool current = _panelState(type);
    _closeAllPanels();
    if (!current) _setPanelState(type, true);
    notifyListeners();
  }

  bool _panelState(_PanelType type) {
    switch (type) {
      case _PanelType.caption:
        return _isShowingCaption;
      case _PanelType.quality:
        return _isShowingQuality;
      case _PanelType.speed:
        return _isShowingSpeed;
      case _PanelType.episode:
        return _isShowingEpisode;
      case _PanelType.aspect:
        return _isShowingAspect;
      case _PanelType.settings:
        return _isShowingSettings;
    }
  }

  void _setPanelState(_PanelType type, bool value) {
    switch (type) {
      case _PanelType.caption:
        _isShowingCaption = value;
        break;
      case _PanelType.quality:
        _isShowingQuality = value;
        break;
      case _PanelType.speed:
        _isShowingSpeed = value;
        break;
      case _PanelType.episode:
        _isShowingEpisode = value;
        break;
      case _PanelType.aspect:
        _isShowingAspect = value;
        break;
      case _PanelType.settings:
        _isShowingSettings = value;
        break;
    }
  }

  Future<void> caption() async {
    if (!_isGoingToOpenOrCaption) {
      _isGoingToOpenOrCaption = true;
      _togglePanel(_PanelType.caption);
      _isGoingToOpenOrCaption = false;
    }
  }

  Future<void> quality() async {
    if (!_isGoingToOpenOrQuality) {
      _isGoingToOpenOrQuality = true;
      _togglePanel(_PanelType.quality);
      _isGoingToOpenOrQuality = false;
    }
  }

  Future<void> speed() async {
    if (!_isGoingToOpenOrSpeed) {
      _isGoingToOpenOrSpeed = true;
      _togglePanel(_PanelType.speed);
      _isGoingToOpenOrSpeed = false;
    }
  }

  Future<void> episode() async {
    if (!_isGoingToOpenOrChat) {
      _isGoingToOpenOrChat = true;
      _togglePanel(_PanelType.episode);
      _isGoingToOpenOrChat = false;
    }
  }

  Future<void> aspect() async {
    if (!_isGoingToOpenOrAspect) {
      _isGoingToOpenOrAspect = true;
      _togglePanel(_PanelType.aspect);
      _isGoingToOpenOrAspect = false;
    }
  }

  // ─── Fullscreen ───────────────────────────────────────────────────────────

  Future<void> openOrCloseFullscreen() async {
    if (!_isGoingToOpenOrCloseFullscreen) {
      _vibrateOnce();
      _isGoingToOpenOrCloseFullscreen = true;
      if (!_isFullScreen) {
        await openFullScreen();
      } else {
        await closeFullScreen();
      }
      _isGoingToOpenOrCloseFullscreen = false;
      notifyListeners();
    }
  }

  Future<void> openFullScreen() async {
    if (context != null && !_isFullScreen) {
      _isFullScreen = true;
      final VideoQuery query = VideoQuery();
      final metadata = query.videoMetadata(context!);
      final Duration transition = metadata.style.transitions;
      Navigator.push(
        context!,
        PageRouteBuilder(
          opaque: false,
          fullscreenDialog: true,
          transitionDuration: transition,
          reverseTransitionDuration: transition,
          pageBuilder: (_, __, ___) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: query.video(context!)),
              Provider.value(value: metadata),
            ],
            child: const FullScreenPage(),
          ),
        ),
      );
    }
  }

  Future<void> closeFullScreen() async {
    if (_isFullScreen) {
      _isFullScreen = false;
      await SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp]);
      // ─── System UI сэргээх ─────────────────────────────────────────
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      if (context != null && Navigator.canPop(context!)) {
        Navigator.of(context!).pop();
      }
    }
  }

  // ─── Aspect ───────────────────────────────────────────────────────────────

  void setAspect(BoxFit aspect) {
    _currentAspect = aspect;
    Utils.setString(key: _aspectKey, value: _boxFitToString(aspect));
    notifyListeners();
  }

  // ─── Lock ─────────────────────────────────────────────────────────────────

  Future<void> openLock() async {
    if (!_isGoingToOpenOrLocked) {
      _vibrateOnce();
      _isGoingToOpenOrLocked = true;
      if (!_isLock) {
        _isLock = true;
        WakelockPlus.enable();
      } else {
        _isLock = false;
        WakelockPlus.disable();
      }
      _isGoingToOpenOrLocked = false;
      notifyListeners();
    }
  }

  // ─── Storage ──────────────────────────────────────────────────────────────

  void _loadPlayerSettingsFromStorage() {
    final String sizeValue = Utils.getString(key: _subtitleSizeKey);
    _currentSubtitleSize = int.tryParse(sizeValue) ?? 23;
    final String aspectValue = Utils.getString(key: _aspectKey);
    _currentAspect = _boxFitFromString(aspectValue);
  }

  String _boxFitToString(BoxFit aspect) => aspect.toString().split('.').last;

  BoxFit _boxFitFromString(String value) => BoxFit.values.firstWhere(
        (e) => e.toString().split('.').last == value,
        orElse: () => BoxFit.cover,
      );

  void _vibrateOnce() => HapticFeedback.lightImpact();
}

extension _DurationClamp on Duration {
  Duration clamp(Duration min, Duration max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}
