import 'dart:convert';
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
    bool autoSubtitle = true,
    String initialSubtitleLanguage = "",
  }) async {
    final String content = await _fetchM3u8Content(m3u8, httpHeaders);
    final Map<String, String> sourceUrls = _parseSourceUrls(content, m3u8);

    Map<String, KenjiPlayerSubtitle>? resolvedSubtitle = subtitle;
    String resolvedInitialSubtitle = initialSubtitle;

    if (autoSubtitle && subtitle == null) {
      final _SubtitleParseResult subResult = await _parseSubtitleTracks(
        content: content,
        baseUrl: m3u8,
        httpHeaders: httpHeaders,
        initialLanguage: initialSubtitleLanguage,
      );

      if (subResult.subtitles.isNotEmpty) {
        resolvedSubtitle = subResult.subtitles;
        resolvedInitialSubtitle = subResult.initialTrackName;
      }
    }

    VideoSource buildSource(String url) => VideoSource(
          video: VideoPlayerController.networkUrl(
            Uri.parse(url),
            httpHeaders: httpHeaders ?? {},
          ),
          intialSubtitle: resolvedInitialSubtitle,
          subtitle: resolvedSubtitle,
          range: range,
          ads: ads,
          httpHeaders: httpHeaders,
        );

    final VideoSource autoSource = buildSource(m3u8);

    final List<MapEntry<String, String>> sortedEntries =
        sourceUrls.entries.toList();
    if (descending) {
      sortedEntries.sort((a, b) {
        final int aH = int.tryParse(a.key.split('x').last) ?? 0;
        final int bH = int.tryParse(b.key.split('x').last) ?? 0;
        return bH.compareTo(aH);
      });
    }

    final Map<String, VideoSource> videoSource = {};
    if (descending) videoSource["Auto"] = autoSource;

    for (final entry in sortedEntries) {
      final String key = formatter?.call(entry.key) ?? entry.key;
      videoSource[key] = buildSource(entry.value);
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

  // ══════════════════════════════════════════════════════════════════════════
  // Private helpers
  // ══════════════════════════════════════════════════════════════════════════

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
          'M3U8 татахад алдаа гарлаа: HTTP ${response.statusCode} — $url');
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
            final String _ = "${match.group(0)}$audio";
          }
        }
      }

      sourceUrls[quality] = playlistUrl;
    }

    return sourceUrls;
  }

  static Future<_SubtitleParseResult> _parseSubtitleTracks({
    required String content,
    required String baseUrl,
    required Map<String, String>? httpHeaders,
    required String initialLanguage,
  }) async {
    // #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",LANGUAGE="mn",NAME="Монгол",URI="subs/mn.m3u8"
    final RegExp subTrackRegex = RegExp(
      r'#EXT-X-MEDIA:TYPE=SUBTITLES'
      r'(?:[^"\n]*,LANGUAGE="([^"]*)")?'
      r'(?:[^"\n]*,NAME="([^"]*)")?'
      r'(?:[^"\n]*,URI="([^"]*)")?',
      caseSensitive: false,
      multiLine: true,
    );

    final RegExp netRegxUrl = RegExp(r'^(http|https):\/\/');
    final RegExp baseRegex = RegExp(r'(.*)\r?\/');

    final List<RegExpMatch> trackMatches =
        subTrackRegex.allMatches(content).toList();

    if (trackMatches.isEmpty) return _SubtitleParseResult.empty();

    final Map<String, KenjiPlayerSubtitle> subtitles = {};
    String initialTrackName = "";

    for (final RegExpMatch match in trackMatches) {
      final String language = match.group(1) ?? "";
      final String name = match.group(2) ?? language;
      final String? rawUri = match.group(3);

      if (rawUri == null || rawUri.isEmpty) continue;

      // Relative URL → absolute URL
      final String trackUrl = netRegxUrl.hasMatch(rawUri)
          ? rawUri
          : "${baseRegex.firstMatch(baseUrl)?.group(0) ?? ''}$rawUri";

      try {
        final String vttContent = await _resolveSubtitleContent(
          trackUrl: trackUrl,
          httpHeaders: httpHeaders,
        );

        if (vttContent.isNotEmpty) {
          subtitles[name] = KenjiPlayerSubtitle.content(vttContent, trackUrl);

          if (initialTrackName.isEmpty) {
            if (initialLanguage.isEmpty ||
                language.toLowerCase() == initialLanguage.toLowerCase() ||
                name.toLowerCase() == initialLanguage.toLowerCase()) {
              initialTrackName = name;
            }
          }
        }
      } catch (e) {
        debugPrint('Subtitle track "$name" татахад алдаа: $e');
      }
    }

    if (initialTrackName.isEmpty && subtitles.isNotEmpty) {
      initialTrackName = subtitles.keys.first;
    }

    return _SubtitleParseResult(
      subtitles: subtitles,
      initialTrackName: initialTrackName,
    );
  }

  static Future<String> _resolveSubtitleContent({
    required String trackUrl,
    required Map<String, String>? httpHeaders,
  }) async {
    final http.Response response = await http.get(
      Uri.parse(trackUrl),
      headers: httpHeaders ?? {},
    );

    if (response.statusCode != 200) {
      throw Exception('Subtitle татахад алдаа: HTTP ${response.statusCode}');
    }

    final String body = utf8.decode(response.bodyBytes);

    if (_isM3u8Content(body)) {
      return _mergeSegmentedVtt(
        playlistContent: body,
        playlistUrl: trackUrl,
        httpHeaders: httpHeaders,
      );
    }

    return body;
  }

  static bool _isM3u8Content(String content) {
    final String trimmed = content.trimLeft();
    return trimmed.startsWith('#EXTM3U') ||
        trimmed.contains('#EXTINF') ||
        trimmed.contains('#EXT-X-TARGETDURATION');
  }

  static Future<String> _mergeSegmentedVtt({
    required String playlistContent,
    required String playlistUrl,
    required Map<String, String>? httpHeaders,
  }) async {
    final RegExp netRegxUrl = RegExp(r'^(http|https):\/\/');
    final RegExp baseRegex = RegExp(r'(.*)\r?\/');
    final RegExp segmentRegex = RegExp(
      r'#EXTINF:([\d.]+),?\r?\n([^\r\n#][^\r\n]*)',
      multiLine: true,
    );

    final List<RegExpMatch> segments =
        segmentRegex.allMatches(playlistContent).toList();

    if (segments.isEmpty) return '';

    final String? basePath = baseRegex.firstMatch(playlistUrl)?.group(0);

    Duration timeOffset = Duration.zero;
    final List<Future<_VttSegment>> futures = [];

    for (final RegExpMatch seg in segments) {
      final double durationSec = double.tryParse(seg.group(1) ?? '0') ?? 0.0;
      final String segPath = seg.group(2)!.trim();
      final String segUrl =
          netRegxUrl.hasMatch(segPath) ? segPath : '${basePath ?? ''}$segPath';

      futures.add(_fetchVttSegment(
        url: segUrl,
        httpHeaders: httpHeaders,
        timeOffset: timeOffset,
      ));

      timeOffset += Duration(milliseconds: (durationSec * 1000).round());
    }

    final List<_VttSegment> results = await Future.wait(futures);
    return _combineVttSegments(results);
  }

  static Future<_VttSegment> _fetchVttSegment({
    required String url,
    required Map<String, String>? httpHeaders,
    required Duration timeOffset,
  }) async {
    try {
      final http.Response res = await http.get(
        Uri.parse(url),
        headers: httpHeaders ?? {},
      );
      if (res.statusCode != 200) {
        return _VttSegment(content: '', offset: timeOffset);
      }
      return _VttSegment(
        content: utf8.decode(res.bodyBytes),
        offset: timeOffset,
      );
    } catch (_) {
      return _VttSegment(content: '', offset: timeOffset);
    }
  }

  static String _combineVttSegments(List<_VttSegment> segments) {
    final StringBuffer buffer = StringBuffer('WEBVTT\n\n');

    // HH:MM:SS.mmm --> HH:MM:SS.mmm
    final RegExp tsRegex = RegExp(
      r'(\d{2}:\d{2}:\d{2}\.\d{3})\s*-->\s*(\d{2}:\d{2}:\d{2}\.\d{3})',
    );

    int cueIndex = 1;

    for (final _VttSegment seg in segments) {
      if (seg.content.isEmpty) continue;

      final List<String> lines =
          seg.content.replaceAll('\r\n', '\n').split('\n');

      int start = 0;
      if (lines.isNotEmpty && lines[0].startsWith('WEBVTT')) {
        start = 1;
        while (start < lines.length && lines[start].trim().isEmpty) start++;
        if (start < lines.length && lines[start].startsWith('NOTE')) {
          while (start < lines.length && lines[start].trim().isNotEmpty) {
            start++;
          }
        }
      }

      final StringBuffer cueBuffer = StringBuffer();
      bool inCue = false;

      for (int i = start; i < lines.length; i++) {
        final String line = lines[i];

        if (tsRegex.hasMatch(line)) {
          inCue = true;
          final String adjusted = line.replaceAllMapped(tsRegex, (m) {
            final Duration s = _parseVttTimestamp(m.group(1)!) + seg.offset;
            final Duration e = _parseVttTimestamp(m.group(2)!) + seg.offset;
            return '${_formatVttTimestamp(s)} --> ${_formatVttTimestamp(e)}';
          });
          cueBuffer.writeln('$cueIndex');
          cueBuffer.writeln(adjusted);
          cueIndex++;
        } else if (inCue) {
          cueBuffer.writeln(line);
          if (line.trim().isEmpty) {
            buffer.write(cueBuffer);
            cueBuffer.clear();
            inCue = false;
          }
        }
      }

      if (cueBuffer.isNotEmpty) {
        buffer.write(cueBuffer);
        buffer.write('\n');
      }
    }

    return buffer.toString();
  }

  /// `HH:MM:SS.mmm` → Duration
  static Duration _parseVttTimestamp(String ts) {
    final List<String> parts = ts.split(':');
    final int hours = int.parse(parts[0]);
    final int minutes = int.parse(parts[1]);
    final List<String> secMs = parts[2].split('.');
    final int seconds = int.parse(secMs[0]);
    final int ms = int.parse(secMs.length > 1 ? secMs[1] : '0');
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: ms,
    );
  }

  /// Duration → `HH:MM:SS.mmm`
  static String _formatVttTimestamp(Duration d) {
    final int h = d.inHours;
    final int m = d.inMinutes.remainder(60);
    final int s = d.inSeconds.remainder(60);
    final int ms = d.inMilliseconds.remainder(1000);
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}.'
        '${ms.toString().padLeft(3, '0')}';
  }
}

// ─── Helper data classes ──────────────────────────────────────────────────────

class _SubtitleParseResult {
  const _SubtitleParseResult({
    required this.subtitles,
    required this.initialTrackName,
  });

  factory _SubtitleParseResult.empty() => const _SubtitleParseResult(
        subtitles: {},
        initialTrackName: '',
      );

  final Map<String, KenjiPlayerSubtitle> subtitles;
  final String initialTrackName;
}

class _VttSegment {
  const _VttSegment({required this.content, required this.offset});
  final String content;
  final Duration offset;
}
