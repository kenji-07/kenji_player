import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:kenji_player/src/data/repositories/video.dart';
import 'package:kenji_player/src/ui/overlay/widgets/progress_bar.dart';
import 'package:kenji_player/src/ui/overlay/widgets/background.dart';
import 'package:kenji_player/src/ui/widgets/helpers.dart';

class OverlayBottom extends StatefulWidget {
  const OverlayBottom({super.key});

  @override
  OverlayBottomState createState() => OverlayBottomState();
}

class OverlayBottomState extends State<OverlayBottom> {
  final ValueNotifier<bool> _showRemaingText = ValueNotifier<bool>(false);
  final VideoQuery _query = VideoQuery();

  @override
  void dispose() {
    _showRemaingText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _query.video(context, listen: true);
    final style = _query.videoStyle(context);
    final metadata = _query.videoMetadata(context, listen: true);

    final barStyle = style.progressBarStyle;

    final bool isFullscreen = controller.isFullScreen;
    final double padding = barStyle.paddingBeetwen;
    final EdgeInsets halfPadding = EdgeInsets.only(left: padding / 2);

    final Duration position = controller.position;
    final Duration duration = controller.duration;

    return GradientBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: (style.textStyle.fontSize ?? 14) + barStyle.bar.height,
          ),
          Padding(
              padding: (isFullscreen)
                  ? EdgeInsets.only(left: 25, right: 25)
                  : EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${_query.durationFormatter(position)} / ${_query.durationFormatter(duration)}',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                  Row(
                    children: [
                      /// Menu
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

                      /// Full Screen
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
              )),
          Padding(
            padding: (isFullscreen)
                ? EdgeInsets.only(bottom: padding, left: 25, right: 25)
                : EdgeInsets.only(bottom: padding, left: 15, right: 15),
            child: const VideoProgressBar(),
          ),
          if (isFullscreen) SizedBox(height: barStyle.bar.height),
        ],
      ),
    );
  }
}
