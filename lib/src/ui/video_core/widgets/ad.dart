import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'package:animax_player/src/ui/widgets/helpers.dart';
import 'package:animax_player/src/data/repositories/video.dart';
import 'package:animax_player/src/ui/widgets/transitions.dart';

class VideoCoreAdViewer extends StatelessWidget {
  const VideoCoreAdViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final style = query.videoStyle(context);
    final video = query.video(context, listen: true);

    return CustomOpacityTransition(
      visible: video.activeAd != null,
      child: Stack(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: video.activeAd?.child,
          ),
          if (video.activeAd != null)
            Positioned(
              right: 20,
              bottom: 20,
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: (video.adTimeWatched ?? Duration.zero) >=
                          video.activeAd!.durationToSkip
                      ? video.skipAd
                      : null,
                  child: Builder(
                    builder: (_) {
                      final int remaing = (video.activeAd!.durationToSkip -
                              (video.adTimeWatched ?? Duration.zero))
                          .inSeconds;
                      return style.skipAdBuilder?.call(video.adTimeWatched!) ??
                          ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(7),
                            ),
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.8),
                              padding: const EdgeInsets.all(5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    remaing > 0
                                        ? "$remaing seconds remaing"
                                        : "Skip ad",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (remaing <= 0)
                                    const Icon(
                                      Iconsax.arrow_right_4,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                    },
                  ),
                ),
              ),
            ),
          Positioned(
            right: 20,
            top: 20,
            child: InkWell(
              onTap: () => Utils.launchURL(video.activeAd!.deepLink),
              child: const Text(
                "Learn More",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
