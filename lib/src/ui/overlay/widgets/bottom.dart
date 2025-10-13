import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:animax_player/src/data/repositories/video.dart';
import 'package:animax_player/src/ui/overlay/widgets/progress_bar.dart';
import 'package:animax_player/src/ui/overlay/widgets/background.dart';
import 'package:animax_player/src/ui/widgets/helpers.dart';

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
    final bool scale = metadata.control;
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
              padding: const EdgeInsets.only(left: 15, right: 15),
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
                      if (!scale)
                        SplashCircularIcon(
                          padding: halfPadding,
                          onTap: () => controller.openSettingsMenu(),
                          child: const Icon(
                            Iconsax.element_equal_copy,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),

                      /// Full Screen
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
                ? EdgeInsets.only(bottom: padding, left: 15, right: 15)
                : EdgeInsets.only(bottom: padding, left: 15, right: 15),
            child: const VideoProgressBar(),
          ),
          if (isFullscreen) SizedBox(height: barStyle.bar.height),
        ],
      ),
    );
  }
}
