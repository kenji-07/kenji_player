import 'package:flutter/material.dart';

import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:kenji_player/src/data/repositories/video.dart';
import 'package:kenji_player/src/ui/overlay/widgets/background.dart';
import 'package:kenji_player/src/ui/overlay/widgets/bottom.dart';
import 'package:kenji_player/src/ui/widgets/center_play_and_pause.dart';
import 'package:kenji_player/src/ui/widgets/transitions.dart';
import 'package:kenji_player/src/ui/widgets/helpers.dart';

class VideoCoreOverlay extends StatelessWidget {
  final Widget child;
  final bool showRewind;
  final bool showForward;
  final bool showSkipStartButton;
  final bool showSkipEndButton;
  final VoidCallback startButton;
  final VoidCallback endButton;
  const VideoCoreOverlay({
    super.key,
    required this.child,
    required this.showRewind,
    required this.showForward,
    required this.showSkipStartButton,
    required this.showSkipEndButton,
    required this.startButton,
    required this.endButton,
  });

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final metadata = query.videoMetadata(context, listen: true);
    final style = query.videoMetadata(context, listen: true).style;
    final controller = query.video(context, listen: true);
    final header = style.header;
    final bool overlayVisible = controller.isShowingOverlay;
    final bool isFullscreen = controller.isFullScreen;

    final bool caption = metadata.caption;

    final barStyle = style.progressBarStyle;
    final double padding = barStyle.paddingBeetwen;
    final EdgeInsets halfPadding = EdgeInsets.all(padding / 2);

    return CustomOpacityTransition(
      visible: !controller.isShowingThumbnail,
      child: Stack(
        children: [
          if (header != null)
            CustomSwipeTransition(
              axisAlignment: 1.0,
              visible: overlayVisible,
              child: GradientBackground(
                end: Alignment.topCenter,
                begin: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
                  child: SizedBox(
                    height: 62,
                    child: Column(
                      children: [
                        child,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: header),
                            Row(
                              children: [
                                /// Aspect
                                SplashCircularIcon(
                                  padding: halfPadding,
                                  onTap: () => controller.aspect(),
                                  child: Icon(
                                    PhosphorIcons.frameCorners(),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),

                                /// Speed
                                SplashCircularIcon(
                                  padding: halfPadding,
                                  onTap: () => controller.speed(),
                                  child: Icon(
                                    PhosphorIcons.gauge(),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),

                                /// CC Caption
                                if (caption)
                                  SplashCircularIcon(
                                    padding: halfPadding,
                                    onTap: () => controller.caption(),
                                    child: Icon(
                                      PhosphorIcons.closedCaptioning(),
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),

                                /// HD
                                SplashCircularIcon(
                                  padding: halfPadding,
                                  onTap: () => controller.quality(),
                                  child: Icon(
                                    PhosphorIcons.highDefinition(),
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  left: isFullscreen ? 30 : 10,
                  right: isFullscreen ? 30 : 10,
                  bottom: 100),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomOpacityTransition(
                      visible: showSkipStartButton,
                      child: GestureDetector(
                          onTap: startButton,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: isFullscreen ? 16 : 10,
                                vertical: isFullscreen ? 10 : 5),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(0, 202, 19, 1.0),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              "Skip OP",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isFullscreen ? 16 : 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))),
                  CustomOpacityTransition(
                      visible: showSkipEndButton,
                      child: GestureDetector(
                          onTap: endButton,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: isFullscreen ? 16 : 10,
                                vertical: isFullscreen ? 10 : 5),
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(0, 202, 19, 1.0),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text(
                              "Skip END",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isFullscreen ? 16 : 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            // widthFactor: widthFactor,
            // heightFactor: heightFactor,
            child: CustomSwipeTransition(
              visible: overlayVisible,
              axisAlignment: -1.0,
              child: const OverlayBottom(),
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) => CustomOpacityTransition(
              visible: overlayVisible ||
                  controller.isChangingSource ||
                  controller.isBuffering,
              child: Center(
                child: CenterPlayAndPause(
                  type: CenterPlayAndPauseType.center,
                  showForward: showForward,
                  showRewind: showRewind,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
