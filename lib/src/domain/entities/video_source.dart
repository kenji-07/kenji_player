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

  // ─── fromNetworkVideoSources ───────────────────────────────────────────────

  static Map<String, VideoSource> fromNetworkVideoSources(
    Map<String, String> sources, {
    String initialSubtitle = "",
    Map<String, KenjiPlayerSubtitle>? subtitle,
    List<KenjiPlayerAd>? ads,
    Tween<Duration>? range,
    Map<String, String>? httpHeaders,
  }) {
    return {
      for (final entry in sources.entries)
        entry.key: VideoSource(
          video: VideoPlayerController.networkUrl(
            Uri.parse(entry.value),
            httpHeaders: httpHeaders ?? {},
          ),
          intialSubtitle: initialSubtitle,
          subtitle: subtitle,
          range: range,
          ads: ads,
          httpHeaders: httpHeaders,
        ),
    };
  }

  // ─── fromM3u8PlaylistUrl ───────────────────────────────────────────────────

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
    final String content = await _fetchM3u8Content(m3u8, httpHeaders);
    final Map<String, String> sourceUrls = _parseSourceUrls(content, m3u8);

    VideoSource _buildSource(String url) => VideoSource(
          video: VideoPlayerController.networkUrl(
            Uri.parse(url),
            httpHeaders: httpHeaders ?? {},
          ),
          intialSubtitle: initialSubtitle,
          subtitle: subtitle,
          range: range,
          ads: ads,
          httpHeaders: httpHeaders,
        );

    final VideoSource autoSource = _buildSource(m3u8);

    final sortedEntries = sourceUrls.entries.toList();
    if (descending) {
      sortedEntries.sort((a, b) {
        final aHeight = int.tryParse(a.key.split('x').last) ?? 0;
        final bHeight = int.tryParse(b.key.split('x').last) ?? 0;
        return bHeight.compareTo(aHeight);
      });
    }

    final Map<String, VideoSource> videoSource = {};

    if (descending) videoSource["Auto"] = autoSource;

    for (final entry in sortedEntries) {
      final String key = formatter?.call(entry.key) ?? entry.key;
      videoSource[key] = _buildSource(entry.value);
    }

    if (!descending) videoSource["Auto"] = autoSource;

    return videoSource;
  }

  // ─── getSource ─────────────────────────────────────────────────────────────

  static Iterable<MapEntry<String, dynamic>> getSource(
    bool descending,
    Map<String, dynamic> sources,
    Map<String, String> sourceUrls,
  ) {
    final Map<String, dynamic> tmp = kIsWeb ? sourceUrls : sources;
    final list = tmp.entries.toList();
    return descending ? list.reversed : list;
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  static Future<String> _fetchM3u8Content(
    String url,
    Map<String, String>? headers,
  ) async {
    final http.Response response = await http.get(
      Uri.parse(url),
      headers: headers ?? {},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'M3U8 татахад алдаа гарлаа: HTTP ${response.statusCode} — $url',
      );
    }

    return utf8.decode(response.bodyBytes);
  }

  static Map<String, String> _parseSourceUrls(String content, String m3u8) {
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

    final List<RegExpMatch> playlistMatches =
        regExpPlaylist.allMatches(content).toList();
    final List<RegExpMatch> audioMatches =
        regExpAudio.allMatches(content).toList();

    final Map<String, String> sourceUrls = {};

    for (final RegExpMatch playlistMatch in playlistMatches) {
      final String? rawSourceURL = playlistMatch.group(3);
      final String? quality = playlistMatch.group(1);

      if (rawSourceURL == null || quality == null) continue;

      final bool isNetwork = netRegxUrl.hasMatch(rawSourceURL);
      String playlistUrl = rawSourceURL;

      if (!isNetwork) {
        final RegExpMatch? baseMatch = netRegx2.firstMatch(m3u8);
        if (baseMatch == null) continue;
        playlistUrl = "${baseMatch.group(0)}$rawSourceURL";
      }

      for (final RegExpMatch audioMatch in audioMatches) {
        final String? audio = audioMatch.group(1);
        if (audio == null) continue;

        final bool audioIsNetwork = netRegxUrl.hasMatch(audio);
        if (!audioIsNetwork) {
          final RegExpMatch? match = netRegx2.firstMatch(playlistUrl);
          if (match != null) {
            // audioUrl нь одоогоор ашиглааагүй
            final String _ = "${match.group(0)}$audio";
          }
        }
      }

      sourceUrls[quality] = playlistUrl;
    }

    return sourceUrls;
  }
}