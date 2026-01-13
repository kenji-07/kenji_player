import 'dart:convert';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kenji_player/src/kenji_player.dart';

class VideoSource {
  VideoSource({
    required this.video,
    this.ads,
    this.subtitle,
    this.intialSubtitle = "",
    this.range,
    this.httpHeaders,
  });
  final List<KenjiPlayerAd>? ads;
  final Tween<Duration>? range;
  final VideoPlayerController video;
  final Map<String, KenjiPlayerSubtitle>? subtitle;
  final String intialSubtitle;
  final Map<String, String>? httpHeaders;

  static Map<String, VideoSource> fromNetworkVideoSources(
    Map<String, String> sources, {
    String initialSubtitle = "",
    Map<String, KenjiPlayerSubtitle>? subtitle,
    List<KenjiPlayerAd>? ads,
    Tween<Duration>? range,
    Map<String, String>? httpHeaders,
  }) {
    Map<String, VideoSource> videoSource = {};
    for (String key in sources.keys) {
      videoSource[key] = VideoSource(
        video: VideoPlayerController.networkUrl(
          Uri.parse(sources[key]!),
          httpHeaders: httpHeaders ?? {},
        ),
        intialSubtitle: initialSubtitle,
        subtitle: subtitle,
        range: range,
        ads: ads,
        httpHeaders: httpHeaders,
      );
    }
    return videoSource;
  }

  static Future<Map<String, VideoSource>> fromM3u8PlaylistUrl(
    String m3u8, {
    String initialSubtitle = "",
    Map<String, KenjiPlayerSubtitle>? subtitle,
    List<KenjiPlayerAd>? ads,
    Tween<Duration>? range,
    String Function(String quality)? formatter,
    bool descending = true,
    Map<String, String>? httpHeaders,
  }) async {
    final RegExp netRegxUrl = RegExp(r'^(http|https):\/\/([\w.]+\/?)\S*');
    final RegExp netRegx2 = RegExp(r'(.*)\r?\/');
    final RegExp regExpPlaylist = RegExp(
      r"#EXT-X-STREAM-INF:(?:.*,RESOLUTION=(\d+x\d+))?,?(.*)\r?\n(.*)",
      caseSensitive: false,
      multiLine: true,
    );
    final RegExp regExpAudio = RegExp(
      r"""^#EXT-X-MEDIA:TYPE=AUDIO(?:.*,URI="(.*m3u8)")""",
      caseSensitive: false,
      multiLine: true,
    );

    late String content = "";
    final http.Response response = await http.get(
      Uri.parse(m3u8),
      headers: httpHeaders ?? {},
    );
    if (response.statusCode == 200) content = utf8.decode(response.bodyBytes);

    List<RegExpMatch> playlistMatches =
        regExpPlaylist.allMatches(content).toList();
    List<RegExpMatch> audioMatches = regExpAudio.allMatches(content).toList();

    Map<String, String> sourceUrls = {};
    final List<String> audioUrls = [];

    for (final RegExpMatch playlistMatch in playlistMatches) {
      final RegExpMatch? playlist = netRegx2.firstMatch(m3u8);
      final String sourceURL = (playlistMatch.group(3)).toString();
      final String quality = (playlistMatch.group(1)).toString();
      final bool isNetwork = netRegxUrl.hasMatch(sourceURL);
      String playlistUrl = sourceURL;

      if (!isNetwork) {
        final String? dataURL = playlist!.group(0);
        playlistUrl = "$dataURL$sourceURL";
      }

      for (final RegExpMatch audioMatch in audioMatches) {
        final String audio = (audioMatch.group(1)).toString();
        final bool isNetwork = netRegxUrl.hasMatch(audio);
        final RegExpMatch? match = netRegx2.firstMatch(playlistUrl);
        String audioUrl = audio;

        if (!isNetwork && match != null) {
          audioUrl = "${match.group(0)}$audio";
        }
        audioUrls.add(audioUrl);
      }

      sourceUrls[quality] = playlistUrl;
    }

    Map<String, VideoSource> videoSource = {};

    void addAutoSource() {
      videoSource["Auto"] = VideoSource(
        video: VideoPlayerController.networkUrl(
          Uri.parse(m3u8),
          httpHeaders: httpHeaders ?? {},
        ),
        intialSubtitle: initialSubtitle,
        subtitle: subtitle,
        range: range,
        ads: ads,
        httpHeaders: httpHeaders,
      );
    }

    if (descending) addAutoSource();

    final sortedEntries = sourceUrls.entries.toList();
    if (descending) {
      sortedEntries.sort((a, b) {
        final aHeight = int.tryParse(a.key.split('x').last) ?? 0;
        final bHeight = int.tryParse(b.key.split('x').last) ?? 0;
        return bHeight.compareTo(aHeight);
      });
    }

    for (final entry in sortedEntries) {
      final String key = formatter?.call(entry.key) ?? entry.key;
      videoSource[key] = VideoSource(
        video: VideoPlayerController.networkUrl(
          Uri.parse(entry.value),
          httpHeaders: httpHeaders ?? {},
        ),
        intialSubtitle: initialSubtitle,
        subtitle: subtitle,
        range: range,
        ads: ads,
        httpHeaders: httpHeaders,
      );
    }

    if (!descending) addAutoSource();
    return videoSource;
  }

  static Iterable<MapEntry<String, dynamic>> getSource(bool descending,
      Map<String, dynamic> sources, Map<String, String> sourceUrls) {
    Map<String, dynamic> tmp = sources;
    if (kIsWeb) {
      tmp = sourceUrls;
    }
    return descending ? tmp.entries.toList().reversed : tmp.entries;
  }
}
