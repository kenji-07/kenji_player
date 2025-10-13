import 'dart:async';
import 'dart:developer';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:animax_player/src/ui/fullscreen.dart';
import 'package:animax_player/src/misc.dart';
import 'package:animax_player/src/domain/entities/ads.dart';
import 'package:animax_player/src/data/repositories/video.dart';
import 'package:animax_player/src/domain/entities/subtitle.dart';
import 'package:animax_player/src/domain/entities/video_source.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:animax_player/src/ui/widgets/helpers.dart';

const int _kMillisecondsToHideTheOverlay = 2800;

class AnimaxPlayerController extends ChangeNotifier
    with WidgetsBindingObserver {
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
  AnimaxPlayerController() {
    isShowingSecondarySettingsMenus.addAll(List.filled(8, false));
  }

  final List<AnimaxPlayerAd> adsSeen = [];
  final List<bool> isShowingSecondarySettingsMenus = [];

  final String _aspectKey = 'currentAspect';
  // Default to BoxFit.cover if no value is stored
  BoxFit _currentAspect = BoxFit.cover;

  late bool looping;

  bool _mounted = false;

  AnimaxPlayerAd? _activeAd;
  Timer? _activeAdTimeRemaing;
  String? _activeSourceName;
  String? _activeSubtitle;
  SubtitleData? _activeSubtitleData;
  Duration? _adTimeWatched;
  List<AnimaxPlayerAd>? _ads;
  Timer? _closeOverlayButtons;
  Duration? _duration;
  bool _isBuffering = false,
      _isShowingOverlay = true,
      _isFullScreen = false,
      _isLock = false,
      _isGoingToCloseOverlay = false,
      _isGoingToOpenOrCloseFullscreen = false,
      _isGoingToOpenOrLoked = false,
      _isGoingToOpenOrChat = false,
      _isGoingToOpenOrCaption = false,
      _isGoingToOpenOrQuality = false,
      _isGoingToOpenOrSpeed = false,
      _isGoingToOpenOrAspect = false,
      _isGoingToOpenOrSettings = false,
      _isShowingThumbnail = true,
      _isShowingSettingsMenu = false,
      _isShowingMainSettingsMenu = false,
      _isDraggingProgressBar = false,
      _isShowingChat = false,
      _isShowingSetttings = false,
      _isShowingCaption = false,
      _isShowingQuality = false,
      _isShowingSpeed = false,
      _isShowingAspect = false,
      _isShowingEposode = false,
      _videoWasPlaying = false,
      _isChangingSource = false;

  BuildContext? context;
  Duration _maxBuffering = Duration.zero;

  Map<String, VideoSource>? _source;

  AnimaxPlayerSubtitle? _subtitle;
  VideoPlayerController? _video;

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

  bool get mounted => _mounted;

  // Duration get position => video!.value.position - beginRange;

  Duration get duration => _duration ?? Duration.zero;

  VideoSource? get activeSource => _source?[_activeSourceName];

  AnimaxPlayerAd? get activeAd => _activeAd;

  Duration? get adTimeWatched => _adTimeWatched;

  VideoPlayerController? get video => _video;

  SubtitleData? get activeCaptionData => _activeSubtitleData;

  List<SubtitleData>? get subtitles => _subtitle?.subtitles;

  AnimaxPlayerSubtitle? get subtitle => _subtitle;

  String? get activeCaption => _activeSubtitle;

  String? get activeSourceName => _activeSourceName;

  Duration get maxBuffering => _maxBuffering;

  bool get isShowingMainSettingsMenu => _isShowingMainSettingsMenu;

  bool get isShowingOverlay => _isShowingOverlay;

  bool get isFullScreen => _isFullScreen;

  bool get isLock => _isLock;

  bool get isPlaying {
    if (_video == null) return false;
    return _video!.value.isPlaying;
  }

  bool get isShowingChat => _isShowingChat;

  bool get isShowingSpeed => _isShowingSpeed;

  bool get isShowingAspect => _isShowingAspect;

  bool get isShowingSetttings => _isShowingSetttings;

  bool get isShowingCaption => _isShowingCaption;

  bool get isShowingQuality => _isShowingQuality;

  bool get isChangingSource => _isChangingSource;

  BoxFit get currentAspect => _currentAspect;

  set isShowingSetttings(bool isShowingSetttings) {
    _isShowingSetttings = isShowingSetttings;
    notifyListeners();
  }

  set isShowingCaption(bool isShowingCaption) {
    _isShowingCaption = isShowingCaption;
    notifyListeners();
  }

  set isShowingQuality(bool isShowingQuality) {
    _isShowingQuality = isShowingQuality;
    notifyListeners();
  }

  set isShowingChat(bool isShowingChat) {
    _isShowingChat = isShowingChat;
    notifyListeners();
  }

  set isShowingSpeed(bool isShowingSpeed) {
    _isShowingSpeed = isShowingSpeed;
    notifyListeners();
  }

  set isShowingAspect(bool isShowingAspect) {
    _isShowingAspect = isShowingAspect;
    notifyListeners();
  }

  bool get isBuffering => _isBuffering;

  set isBuffering(bool value) {
    _isBuffering = value;
    notifyListeners();
  }

  bool get isShowingSettingsMenu => _isShowingSettingsMenu;

  set isShowingSettingsMenu(bool value) {
    _isShowingSettingsMenu = value;
    notifyListeners();
  }

  bool get isShowingThumbnail => _isShowingThumbnail;

  set isShowingThumbnail(bool value) {
    _isShowingThumbnail = value;
    notifyListeners();
  }

  bool get isDraggingProgressBar => _isDraggingProgressBar;

  set isDraggingProgressBar(bool value) {
    _isDraggingProgressBar = value;
    notifyListeners();
  }

  Map<String, VideoSource>? get source => _source;

  set source(Map<String, VideoSource>? value) {
    _source = value;
    notifyListeners();
  }

  //-----------------//
  //SOURCE CONTROLLER//
  //-----------------//
  @override
  void notifyListeners() {
    if (mounted) super.notifyListeners();
  }

  Future<void> initialize(
    Map<String, VideoSource> sources, {
    bool autoPlay = true,
  }) async {
    WidgetsBinding.instance.addObserver(this);
    final MapEntry<String, VideoSource> entry = sources.entries.first;
    _mounted = true;
    _source = sources;
    await changeSource(
      name: entry.key,
      source: entry.value,
      autoPlay: autoPlay,
    );
    // Load the stored aspect ratio when the controller is initialized
    _loadAspectFromStorage();
    print("VIDEO PLAYER INITIALIZED");
    // Wakelock.enable();
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    _mounted = false;
    _closeOverlayButtons?.cancel();
    _deleteAdTimer();
    _video?.removeListener(_videoListener);
    _video?.pause();
    _video?.dispose();
    // Wakelock.disable();
    print("VIDEO PLAYER DISPOSED");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      print("APP PAUSED");
      _videoWasPlaying = isPlaying;
      if (_videoWasPlaying) pause();
    } else if (state == AppLifecycleState.resumed) {
      print("APP RESUMED");
      if (_videoWasPlaying) play();
    }
  }

  ///The [source.video] must be initialized previously
  ///
  ///[inheritPosition] has the function to inherit last controller values.
  ///It's useful on changed quality video.
  ///
  ///For example:
  ///```dart
  ///   _video.seekTo(lastController.value.position);
  /// ```
  Future<void> changeSource({
    required VideoSource source,
    required String name,
    bool inheritPosition = true,
    bool autoPlay = true,
  }) async {
    final double speed = _video?.value.playbackSpeed ?? 1.0;
    final double volume = _video?.value.volume ?? 1.0;
    final Duration lastPositon = _video != null ? position : Duration.zero;

    // Өмнөх видеог listener-гүй болгох
    if (_video != null) {
      _video!.removeListener(_videoListener);
      _isChangingSource = true;
      notifyListeners();

      // Өмнөх видеог зогсоож dispose хийх
      await _video!.pause();
      await Future.delayed(Duration(milliseconds: 100)); // Жаахан хүлээх
    }

    // Хадмал орчуулгыг өөрчлөх
    if (source.subtitle != null) {
      final subtitle = source.subtitle![source.intialSubtitle];
      if (subtitle != null) {
        changeSubtitle(subtitle: subtitle, subtitleName: source.intialSubtitle);
      }
    }

    // Үзсэн бүх зарыг устгах
    _ads = source.ads;
    if (_ads != null) {
      for (int i = 0; i < _ads!.length; i++) {
        for (final adSeen in adsSeen) {
          if (_ads![i] == adSeen) _ads?.removeAt(i);
        }
      }
    }

    try {
      // Шинэ видеог initialize хийх
      await source.video.initialize();

      // Өмнөх видеог dispose хийх (шинэ видео амжилттай ачааллагдсаны дараа)
      final oldVideo = _video;
      _video = source.video;

      if (oldVideo != null) {
        await oldVideo.dispose();
      }

      // Listener нэмэх
      _video!.addListener(_videoListener);
      _activeSourceName = name;
      _duration = endRange - beginRange;
      _isChangingSource = false;
      notifyListeners();

      // Тохиргоог шинэчлэх
      await _video?.setPlaybackSpeed(speed);
      await _video?.setLooping(looping);
      await _video?.setVolume(volume);

      if (inheritPosition && lastPositon > Duration.zero) {
        await seekTo(lastPositon);
      } else if (source.range != null) {
        await seekTo(beginRange);
      }

      if (autoPlay) {
        await Future.delayed(
            Duration(milliseconds: 200)); // Жаахан хүлээгээд тоглуулах
        await play();
      }
    } catch (e) {
      _isChangingSource = false;
      notifyListeners();
      print("Error changing source: $e");
      rethrow;
    }
  }

  Future<void> changeSubtitle({
    required AnimaxPlayerSubtitle? subtitle,
    required String subtitleName,
  }) async {
    _activeSubtitle = subtitleName;
    _activeSubtitleData = null;
    _subtitle = subtitle;
    if (subtitle != null) await _subtitle!.initialize();
    notifyListeners();
  }

  //-------------//
  //VIDEO CONTROL//
  //-------------//

  Future<void> playOrPause() async {
    _vibrateOnce();
    if (isPlaying) {
      await pause();
    } else {
      await _seekToBegin();
      await play();
    }
  }

  Future<void> play() async {
    if (!_isChangingSource) {
      if (looping) _seekToBegin();
      if (_activeAd == null) await _video?.play();
    }
  }

  Future<void> pause() async {
    if (!_isChangingSource) {
      await _video?.pause();
    }
  }

  Future<void> _seekToBegin() async {
    if (position >= duration) await seekTo(beginRange);
  }

  Future<void> seekTo(Duration position) async {
    if (!_isChangingSource) {
      final Duration end = endRange;
      final Duration begin = beginRange;
      if (position < begin) {
        position = begin;
      } else if (position > end) {
        position = end;
      }
      await _video?.seekTo(position);
    }
  }

  void _videoListener() {
    final VideoPlayerValue value = _video!.value;
    final Tween<Duration>? range = activeSource?.range;
    final Duration position = value.position;
    final Duration duration = value.duration;
    final bool buffering = value.isBuffering;

    //Cut the video from Source range
    if (range != null) {
      final Duration end = endRange;
      final Duration begin = beginRange;
      if (position < begin || position >= end) {
        if (looping) {
          _video?.seekTo(begin);
        } else if (isPlaying && position >= end) {
          _video?.pause();
        }
      }
    }

    //Hide the Thumbnail when the player is playing for first time
    if (isPlaying && isShowingThumbnail) {
      _isShowingThumbnail = false;
      notifyListeners();
    }

    //Show the Buffering Widget
    if (_isBuffering != buffering && !_isDraggingProgressBar) {
      _isBuffering = buffering;
      notifyListeners();
    }

    //Update the buffering progress bar
    _maxBuffering = Duration.zero;
    for (DurationRange range in _video!.value.buffered) {
      final Duration end = range.end;
      if (end > maxBuffering) {
        _maxBuffering = end;
        notifyListeners();
      }
    }

    //Hide the overlay after _kMillisecondsToHideTheOverlay milliseconds
    //when the video is playing
    if (_isShowingOverlay) {
      if (isPlaying) {
        if (position >= duration && looping) {
          seekTo(Duration.zero);
        } else {
          if (_closeOverlayButtons == null) _startCloseOverlay();
        }
      } else if (_isGoingToCloseOverlay) cancelCloseOverlay();
    }

    //Одоогийн хадмал орчуулгыг харуулах
    if (_subtitle != null) {
      if (_activeSubtitleData != null) {
        if (!(position > _activeSubtitleData!.start &&
            position < _activeSubtitleData!.end)) _findSubtitle();
      } else {
        _findSubtitle();
      }
    }

    //Show the current Ad
    if (_ads != null) {
      if (_activeAd != null) {
        final Duration start = _getAdStartTime(_activeAd!);
        if (!(position > start &&
            position < start + _activeAd!.durationToEnd)) {
          _findAd();
        }
      } else {
        _findAd();
      }
    }
  }

  //---//
  //ADS//
  //---//
  Future<void> skipAd() async {
    _activeAd = null;
    _deleteAdTimer();
    await play();
    notifyListeners();
  }

  void _findAd() async {
    final Duration position = this.position;
    bool foundOne = false;

    for (AnimaxPlayerAd ad in _ads!) {
      final Duration start = _getAdStartTime(ad);
      if (position > start &&
          position < start + ad.durationToEnd &&
          _activeAd != ad) {
        _activeAd = ad;
        await _video?.pause();
        _ads?.remove(ad);
        _createAdTimer();
        adsSeen.add(ad);
        foundOne = true;
        notifyListeners();
        break;
      }
    }

    if (!foundOne && _activeAd != null) {
      _activeAd = null;
      _deleteAdTimer();
      notifyListeners();
    }
  }

  Duration _getAdStartTime(AnimaxPlayerAd ad) {
    final double? fractionToStart = ad.fractionToStart;
    final Duration? durationToStart = ad.durationToStart;
    return durationToStart ?? duration * fractionToStart!;
  }

  void _createAdTimer() {
    final Duration refreshDuration = Duration(milliseconds: 500);
    _activeAdTimeRemaing = Timer.periodic(refreshDuration, (timer) {
      if (_adTimeWatched == null) {
        _adTimeWatched = refreshDuration;
      } else {
        _adTimeWatched = _adTimeWatched! + refreshDuration;
      }

      if (_activeAd != null) {
        if (_adTimeWatched! >= _activeAd!.durationToSkip) {
          timer.cancel();
        }
      }
      notifyListeners();
    });
  }

  void _deleteAdTimer() {
    _activeAdTimeRemaing?.cancel();
    _activeAdTimeRemaing = null;
  }

  //---------//
  //ХАДМАЛ ОРЧУУЛГА//
  //---------//
  void _findSubtitle() {
    final Duration position = _video!.value.position;
    bool foundOne = false;
    for (SubtitleData subtitle in subtitles!) {
      if (position > subtitle.start &&
          position < subtitle.end &&
          _activeSubtitleData != subtitle) {
        _activeSubtitleData = subtitle;
        foundOne = true;
        notifyListeners();
        break;
      }
    }
    if (!foundOne && _activeSubtitleData != null) {
      _activeSubtitleData = null;
      notifyListeners();
    }
  }

  //-----//
  //TIMER//
  //-----//
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

  //-------//
  //OVERLAY//
  //-------//
  void showAndHideOverlay([bool? show]) {
    if (!isShowingChat &&
        !isShowingSpeed &&
        !isShowingAspect &&
        !isShowingCaption &&
        !isShowingQuality &&
        !isShowingSetttings) {
      _isShowingOverlay = show ?? !_isShowingOverlay;
      if (_isShowingOverlay) cancelCloseOverlay();
      notifyListeners();
    } else {
      isShowingChat = false;
      isShowingSpeed = false;
      isShowingAspect = false;
      isShowingCaption = false;
      isShowingQuality = false;
      isShowingSetttings = false;
    }
  }

  //-------------//
  //SETTINGS MENU//
  //-------------//
  void closeAllSecondarySettingsMenus() {
    _isShowingMainSettingsMenu = true;
    isShowingSecondarySettingsMenus.fillRange(
      0,
      isShowingSecondarySettingsMenus.length,
      false,
    );
    notifyListeners();
  }

  void openSecondarySettingsMenu(int index) {
    _isShowingSettingsMenu = true;
    _isShowingMainSettingsMenu = false;
    isShowingSecondarySettingsMenus[index] = true;
    notifyListeners();
  }

  void openSecondarySettingsSpeed(int index) {
    isShowingSecondarySettingsMenus[index] = true;
    notifyListeners();
  }

  void openSettingsMenu() {
    _isShowingSettingsMenu = true;
    _isShowingMainSettingsMenu = true;
    notifyListeners();
  }

  void closeSettingsMenu() {
    _isShowingSettingsMenu = false;
    _isShowingMainSettingsMenu = false;
    notifyListeners();
  }

  //----------//
  //FULLSCREEN//
  //----------//
  Future<void> openOrCloseFullscreen() async {
    if (!_isGoingToOpenOrCloseFullscreen) {
      _vibrateOnce();
      _isGoingToOpenOrCloseFullscreen = true;
      if (!_isFullScreen) {
        await openFullScreen(seekTo);
      } else {
        await closeFullScreen();
      }
      _isGoingToOpenOrCloseFullscreen = false;
    }
    notifyListeners();
  }

  ///When you want to open FullScreen Page, you need pass the FullScreen's context,
  Future<void> openFullScreen(seekTo) async {
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

  ///When you want to close FullScreen Page, you need pass the FullScreen's context,
  Future<void> closeFullScreen() async {
    if (_isFullScreen) {
      _isFullScreen = false;

      // Reset orientation to portrait mode
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // Pop the fullscreen page from the navigation stack
      if (Navigator.canPop(context!)) {
        Navigator.of(context!).pop();
      }
    }
  }

  //----------//
  ///CAPTION//
  //----------//
  Future<void> caption() async {
    if (!_isGoingToOpenOrCaption) {
      _isGoingToOpenOrCaption = true;
      if (!isShowingCaption) {
        await _caption();
      } else {
        await _isCaption();
      }
      _isGoingToOpenOrCaption = false;
    }
    notifyListeners();
  }

  Future<void> _caption() async {
    if (context != null && !isShowingCaption) {
      isShowingCaption = true;
      isShowingChat = false;
      isShowingSpeed = false;
      isShowingAspect = false;
      isShowingQuality = false;
      isShowingSetttings = false;
    }
  }

  Future<void> _isCaption() async {
    if (isShowingCaption) {
      isShowingCaption = false;
    }
  }

  //----------//
  ///QUALITY//
  //----------//
  Future<void> quality() async {
    if (!_isGoingToOpenOrQuality) {
      _isGoingToOpenOrQuality = true;
      if (!isShowingQuality) {
        await _quality();
      } else {
        await _isQuality();
      }
      _isGoingToOpenOrQuality = false;
    }
    notifyListeners();
  }

  Future<void> _quality() async {
    if (context != null && !isShowingQuality) {
      isShowingQuality = true;
      isShowingChat = false;
      isShowingSpeed = false;
      isShowingAspect = false;
      isShowingCaption = false;
      isShowingSetttings = false;
    }
  }

  Future<void> _isQuality() async {
    if (isShowingQuality) {
      isShowingQuality = false;
    }
  }

  //----------//
  ///SETTINGS//
  //----------//
  Future<void> settings() async {
    if (!_isGoingToOpenOrSettings) {
      _isGoingToOpenOrSettings = true;
      if (!isShowingSetttings) {
        await _settings();
      } else {
        await _isSettings();
      }
      _isGoingToOpenOrSettings = false;
    }
    notifyListeners();
  }

  Future<void> _settings() async {
    if (context != null && !isShowingSetttings) {
      isShowingSetttings = true;
      isShowingChat = false;
      isShowingSpeed = false;
      isShowingAspect = false;
      isShowingCaption = false;
      isShowingQuality = false;
    }
  }

  Future<void> _isSettings() async {
    if (isShowingSetttings) {
      isShowingSetttings = false;
    }
  }

  //----------//
  ///SPEED//
  //----------//
  Future<void> speed() async {
    if (!_isGoingToOpenOrSpeed) {
      _isGoingToOpenOrSpeed = true;
      if (!isShowingSpeed) {
        await _speeds();
      } else {
        await _isSpeed();
      }
      _isGoingToOpenOrSpeed = false;
    }
    notifyListeners();
  }

  Future<void> _speeds() async {
    if (context != null && !isShowingSpeed) {
      isShowingSpeed = true;
      isShowingChat = false;
      isShowingAspect = false;
      isShowingCaption = false;
      isShowingQuality = false;
      isShowingSetttings = false;
    }
  }

  Future<void> _isSpeed() async {
    if (isShowingSpeed) {
      isShowingSpeed = false;
    }
  }

  //----------//
  ///CHAT//
  //----------//
  Future<void> chat() async {
    if (!_isGoingToOpenOrChat) {
      _isGoingToOpenOrChat = true;
      if (!isShowingChat) {
        await _chat();
      } else {
        await _isChat();
      }
      _isGoingToOpenOrChat = false;
    }
    notifyListeners();
  }

  Future<void> _chat() async {
    if (context != null && !isShowingChat) {
      isShowingChat = true;
      isShowingSpeed = false;
      isShowingAspect = false;
      isShowingCaption = false;
      isShowingQuality = false;
      isShowingSetttings = false;
    }
  }

  Future<void> _isChat() async {
    if (isShowingChat) {
      isShowingChat = false;
    }
  }

  Future<void> aspect() async {
    if (!_isGoingToOpenOrAspect) {
      _isGoingToOpenOrAspect = true;
      if (!isShowingAspect) {
        await _aspect();
      } else {
        await _isAspect();
      }
      _isGoingToOpenOrAspect = false;
    }
    notifyListeners();
  }

  Future<void> _aspect() async {
    if (context != null && !isShowingAspect) {
      isShowingAspect = true;
      isShowingSpeed = false;
      isShowingChat = false;
      isShowingCaption = false;
      isShowingQuality = false;
      isShowingSetttings = false;
    }
  }

  Future<void> _isAspect() async {
    if (isShowingChat) {
      isShowingChat = false;
    }
  }

  void setAspect(BoxFit aspect) {
    _currentAspect = aspect;
    _saveAspectToStorage(aspect); // Save the new value to GetStorage
    notifyListeners();
  }

  void _loadAspectFromStorage() {
    final storedValue = Utils.getString(key: _aspectKey);
    if (storedValue != null) {
      _currentAspect = _boxFitFromString(storedValue);
    }
  }

  void _saveAspectToStorage(BoxFit aspect) {
    Utils.setString(key: _aspectKey, value: _boxFitToString(aspect));
  }

  String _boxFitToString(BoxFit aspect) {
    return aspect
        .toString()
        .split('.')
        .last; // Convert to string (e.g., 'cover')
  }

  BoxFit _boxFitFromString(String value) {
    return BoxFit.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => BoxFit.cover,
    );
  }

  //----------//
  ///LOCK//
  //----------//
  Future<void> openLock() async {
    if (!_isGoingToOpenOrLoked) {
      _vibrateOnce();
      _isGoingToOpenOrLoked = true;
      if (!_isLock) {
        await _lock();
      } else {
        await _locked();
      }
      _isGoingToOpenOrLoked = false;
    }
    notifyListeners();
  }

  Future<void> _lock() async {
    if (context != null && !_isLock) {
      _isLock = true;
      WakelockPlus.enable();
    }
  }

  Future<void> _locked() async {
    if (_isLock) {
      _isLock = false;
      WakelockPlus.disable();
    }
  }

  Future<void> _vibrateOnce() async {
    HapticFeedback.lightImpact();
  }
}
