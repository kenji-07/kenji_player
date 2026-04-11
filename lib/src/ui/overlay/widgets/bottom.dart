import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:kenji_player/src/data/repositories/video.dart';
import 'package:kenji_player/src/ui/overlay/widgets/progress_bar.dart';
import 'package:kenji_player/src/ui/overlay/widgets/background.dart';
import 'package:kenji_player/src/ui/widgets/helpers.dart';

class OverlayBottom extends StatelessWidget {
  const OverlayBottom({super.key});

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final controller = query.video(context, listen: true);
    final style = query.videoStyle(context);
    final metadata = query.videoMetadata(context, listen: true);

    final barStyle = style.progressBarStyle;
    final bool isFullscreen = controller.isFullScreen;
    final double padding = barStyle.paddingBeetwen;
    final EdgeInsets halfPadding = EdgeInsets.only(left: padding / 2);

    return GradientBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: barStyle.bar.height,
          ),
          if (style.buttom != null) style.buttom!,
          SizedBox(
            height: (style.textStyle.fontSize ?? 14),
          ),
          Padding(
            padding: isFullscreen
                ? const EdgeInsets.symmetric(horizontal: 25)
                : const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                controller.isLive
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('LIVE',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      )
                    : Text(
                        '${query.durationFormatter(controller.position)} / ${query.durationFormatter(controller.duration)}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                Row(
                  children: [
                    if (style.episode != null && !controller.isShowingEpisode)
                      SplashCircularIcon(
                        padding: halfPadding,
                        onTap: () => controller.episode(),
                        child: Icon(
                          PhosphorIcons.gear(),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    if (metadata.enableFullscreenScale)
                      SplashCircularIcon(
                        padding: halfPadding,
                        onTap: () => controller.openOrCloseFullscreen(),
                        child: isFullscreen
                            ? barStyle.fullScreenExit
                            : barStyle.fullScreen,
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (!controller.isLive)
            Padding(
              padding: isFullscreen
                  ? EdgeInsets.only(bottom: padding, left: 25, right: 25)
                  : EdgeInsets.only(bottom: padding, left: 15, right: 15),
              child: const VideoProgressBar(),
            )
          else
            SizedBox(height: padding),
          if (isFullscreen) SizedBox(height: barStyle.bar.height),
        ],
      ),
    );
  }
}
