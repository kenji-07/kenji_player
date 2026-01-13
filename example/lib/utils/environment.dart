class ResolutionUrl {
  final String quality;
  final String qualityUrl;

  ResolutionUrl({
    required this.quality,
    required this.qualityUrl,
  });
}

class SubtitleUrl {
  final String subtitleLang;
  final String subtitleUrl;

  SubtitleUrl({
    required this.subtitleLang,
    required this.subtitleUrl,
  });
}

class SubtitleDecryptUrl {
  final String subtitleLang;
  final String subtitleUrl;
  final String subtitleKey;
  final String subtitleIv;

  SubtitleDecryptUrl({
    required this.subtitleLang,
    required this.subtitleUrl,
    required this.subtitleKey,
    required this.subtitleIv,
  });
}

class Environment {
  /// 🎞 Видео чанаруудын жагсаалт (жишээ нь 360p, 720p, 1080p)
  static List<ResolutionUrl> resolutionsUrls = [
    ResolutionUrl(
      quality: "360p",
      qualityUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/CastVideos/mp4/DesigningForGoogleCast.mp4",
    ),
    ResolutionUrl(
      quality: "480p",
      qualityUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/CastVideos/mp4/ForBiggerBlazes.mp4",
    ),
    ResolutionUrl(
      quality: "720p",
      qualityUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/CastVideos/mp4/GoogleIO-2014-CastingToTheFuture.mp4",
    ),
    ResolutionUrl(
      quality: "1080p",
      qualityUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/CastVideos/mp4/GoogleIO-2014-MakingGoogleCastReadyAppsDiscoverable.mp4",
    ),
    ResolutionUrl(
      quality: "4k",
      qualityUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/CastVideos/mp4/TearsOfSteel.mp4",
    ),
  ];

  /// 💬 Субтайтлуудын жагсаалт
  static List<SubtitleUrl> subtitleUrls = [
    SubtitleUrl(
      subtitleLang: "English",
      subtitleUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/CastVideos/tracks/DesigningForGoogleCast-en.vtt",
    ),
    SubtitleUrl(
      subtitleLang: "Монгол",
      subtitleUrl:
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/CastVideos/tracks/GoogleIO-2014-MakingGoogleCastReadyAppsDiscoverable-en.vtt",
    ),
  ];

  static List<SubtitleDecryptUrl> subtitleDecryptUrls = [
    SubtitleDecryptUrl(
        subtitleLang: "English",
        subtitleUrl:
            "https://cdn.cdn3.co/storage/subtitle/7cd95246-6d8d-48bf-bae4-d7f64bb994ed.vtt",
        subtitleKey: "0123456789abcdef0123456789abcdef",
        subtitleIv: "0123456789abcdef0123456789abcdef"),
  ];

  /// 🌐 Default субтайтл (англи гэх мэт)
  static String? intialSubtitle = "English";
}
