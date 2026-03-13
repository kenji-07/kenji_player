import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';

enum SubtitleType { webvtt, srt }

enum SubtitleIntializeType { network, decrypt, string }

class SubtitleData {
  SubtitleData({
    this.start = Duration.zero,
    this.end = Duration.zero,
    this.text = "",
    required this.url,
  });

  final Duration start;
  final Duration end;
  final String text;
  final String url;
}

class KenjiPlayerSubtitle {
  SubtitleIntializeType intializedType;
  final SubtitleType type;

  late String content;
  late String url_;

  final String? keyHex;
  final String? ivHex;

  final List<SubtitleData> subtitles_ = [];

  KenjiPlayerSubtitle.network(
    this.url_, {
    this.type = SubtitleType.webvtt,
  })  : intializedType = SubtitleIntializeType.network,
        keyHex = null,
        ivHex = null;

  KenjiPlayerSubtitle.content(
    this.content,
    this.url_, {
    this.type = SubtitleType.webvtt,
  })  : intializedType = SubtitleIntializeType.string,
        keyHex = null,
        ivHex = null;

  KenjiPlayerSubtitle.decrypt(
    this.url_, {
    required this.keyHex,
    required this.ivHex,
    this.type = SubtitleType.webvtt,
  }) : intializedType = SubtitleIntializeType.decrypt;

  Future<void> initialize() async {
    switch (intializedType) {
      case SubtitleIntializeType.network:
        final response = await http.get(Uri.parse(url_));
        if (response.statusCode == 200) {
          content = utf8.decode(response.bodyBytes);
          _getSubtitlesData();
        } else {
          content = '';
        }
        break;

      case SubtitleIntializeType.decrypt:
        final response = await http.get(Uri.parse(url_));
        if (response.statusCode == 200) {
          final raw = utf8.decode(response.bodyBytes);
          content = _decryptCdnSubtitleText(
            raw,
            keyHex: keyHex!,
            ivHex: ivHex!,
          );
          _getSubtitlesData();
        } else {
          content = '';
        }
        break;

      case SubtitleIntializeType.string:
        _getSubtitlesData();
        break;
    }
  }

  List<SubtitleData> get subtitles => subtitles_;

  void _getSubtitlesData() {
    late RegExp regExp;

    switch (type) {
      case SubtitleType.webvtt:
        regExp = RegExp(
          r'(\d+)?\n(?:(\d{1,}):)?(?:(\d{1,2}):)?(\d{1,2})[.,]+(\d+)\s*-->\s*(?:(\d{1,2}):)?(?:(\d{1,2}):)?(\d{1,2}).(\d+)(?:.*(?:\r?(?!\r?).*)*)\n(.*(?:\r?\n(?!\r?\n).*)*)',
          caseSensitive: false,
          multiLine: true,
        );
        break;

      case SubtitleType.srt:
        regExp = RegExp(
          r'((\d{2}):(\d{2}):(\d{2})\,(\d+)) +--> +((\d{2}):(\d{2}):(\d{2})\,(\d{3})).*[\r\n]+\s*((?:(?!\r?\n\r?).)*(\r\n|\r|\n)(?:.*))',
          caseSensitive: false,
          multiLine: true,
        );
        break;
    }

    final matches = regExp.allMatches(content).toList();

    for (final m in matches) {
      var minutes = 0;
      var hours = 0;

      if (m.group(3) == null && m.group(2) != null) {
        minutes = int.parse(m.group(2)?.replaceAll(':', '') ?? '0');
      } else {
        minutes = int.parse(m.group(3)?.replaceAll(':', '') ?? '0');
        hours = int.parse(m.group(2)?.replaceAll(':', '') ?? '0');
      }

      final start = Duration(
        seconds: int.parse(m.group(4)?.replaceAll(':', '') ?? '0'),
        minutes: minutes,
        hours: hours,
        milliseconds: int.parse(m.group(5) ?? '0'),
      );

      minutes = 0;
      hours = 0;

      if (m.group(7) == null && m.group(6) != null) {
        minutes = int.parse(m.group(6)?.replaceAll(':', '') ?? '0');
      } else {
        minutes = int.parse(m.group(7)?.replaceAll(':', '') ?? '0');
        hours = int.parse(m.group(6)?.replaceAll(':', '') ?? '0');
      }

      final end = Duration(
        seconds: int.parse(m.group(8)?.replaceAll(':', '') ?? '0'),
        minutes: minutes,
        hours: hours,
        milliseconds: int.parse(m.group(9) ?? '0'),
      );

      final text = _removeAllHtmlTags(m.group(10)!);

      subtitles_.add(
        SubtitleData(start: start, end: end, text: text.trim(), url: url_),
      );
    }
  }

  String _removeAllHtmlTags(String htmlText) {
    final exp = RegExp(r'(<[^>]*>)', multiLine: true, caseSensitive: true);
    var out = htmlText;

    for (final m in exp.allMatches(htmlText)) {
      if (m.group(0) == '<br>') {
        out = out.replaceAll(m.group(0)!, '\n');
      } else {
        out = out.replaceAll(m.group(0)!, '');
      }
    }
    return out;
  }

  String _decryptCdnSubtitleText(
    String fileText, {
    required String keyHex,
    required String ivHex,
  }) {
    final input = fileText.trim();
    String decoded;
    try {
      final b64 = input.replaceAll(RegExp(r'\s+'), '');
      decoded = utf8.decode(base64Decode(b64));
    } catch (_) {
      decoded = input;
    }

    final lines =
        decoded.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');

    final key = _hexToBytes(keyHex);
    final iv = _hexToBytes(ivHex);
    if (key.length != 16 || iv.length != 16) {
      throw ArgumentError('key/iv must be 16 bytes (32 hex chars)');
    }

    final timestampRegex = RegExp(
      r'^\d{2}:\d{2}:\d{2}\.\d{3} --> \d{2}:\d{2}:\d{2}\.\d{3}$',
    );

    bool isHexLine(String s) =>
        s.isNotEmpty &&
        (s.length % 2 == 0) &&
        RegExp(r'^[0-9a-fA-F]+$').hasMatch(s);

    bool isCueId(String s) => s.length == 32 && isHexLine(s);

    final out = <String>[];

    for (final line in lines) {
      final t = line.trimRight();
      final tt = t.trim();

      if (tt.isEmpty || tt == 'WEBVTT' || timestampRegex.hasMatch(tt)) {
        out.add(line);
        continue;
      }

      if (isCueId(tt)) {
        out.add(line);
        continue;
      }

      if (isHexLine(tt)) {
        try {
          final plain = _decryptHexLineAesCbcPkcs7(tt, key, iv);
          out.add(plain);
          continue;
        } catch (_) {
          out.add(line);
          continue;
        }
      }

      out.add(line);
    }

    return out.join('\n');
  }

  String _decryptHexLineAesCbcPkcs7(
      String hexCipher, Uint8List key, Uint8List iv) {
    final encBytes = _hexToBytes(hexCipher);

    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESFastEngine()),
    );

    cipher.init(
      false,
      PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ParametersWithIV<KeyParameter>(KeyParameter(key), iv),
        null,
      ),
    );

    final plainBytes = cipher.process(encBytes);
    return utf8.decode(plainBytes, allowMalformed: true);
  }

  Uint8List _hexToBytes(String hex) {
    final cleaned = hex.trim();
    if (cleaned.length % 2 != 0) {
      throw FormatException('Invalid hex length');
    }
    final out = Uint8List(cleaned.length ~/ 2);
    for (int i = 0; i < cleaned.length; i += 2) {
      out[i ~/ 2] = int.parse(cleaned.substring(i, i + 2), radix: 16);
    }
    return out;
  }
}
