import 'package:flutter/material.dart';

import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'package:animax_player/src/data/repositories/video.dart';
import 'package:animax_player/src/ui/settings_menu/settings_menu.dart';
import 'package:animax_player/src/ui/overlay/widgets/background.dart';
import 'package:animax_player/src/ui/overlay/widgets/bottom.dart';
import 'package:animax_player/src/ui/widgets/center_play_and_pause.dart';
import 'package:animax_player/src/ui/widgets/transitions.dart';
import 'package:animax_player/src/ui/widgets/helpers.dart';

class VideoCoreOverlay extends StatelessWidget {
  final Widget child;
  final bool showRewind;
  final bool showForward;
  const VideoCoreOverlay({
    super.key,
    required this.child,
    required this.showRewind,
    required this.showForward,
  });

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final metadata = query.videoMetadata(context, listen: true);
    final style = query.videoMetadata(context, listen: true).style;
    final controller = query.video(context, listen: true);
    final header = style.header;
    final bool overlayVisible = controller.isShowingOverlay;

    final bool caption = metadata.caption;

    final bool scale = metadata.control;

    final barStyle = style.progressBarStyle;
    final double padding = barStyle.paddingBeetwen;
    final EdgeInsets halfPadding = EdgeInsets.all(padding / 2);

    return CustomOpacityTransition(
      visible: !controller.isShowingThumbnail,
      child: Stack(
        children: [
          if (!scale)
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
                                  if (!scale)
                                    SplashCircularIcon(
                                      padding: halfPadding,
                                      onTap: () => controller.aspect(),
                                      child: const Icon(
                                        Iconsax.toggle_off_copy,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),

                                  /// Speed
                                  if (!scale)
                                    SplashCircularIcon(
                                      padding: halfPadding,
                                      onTap: () => controller.speed(),
                                      child: const Icon(
                                        Iconsax.timer_1_copy,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),

                                  /// CC Caption
                                  if (!scale)
                                    if (caption)
                                      SplashCircularIcon(
                                        padding: halfPadding,
                                        onTap: () => controller.caption(),
                                        child: const Icon(
                                          Iconsax.creative_commons_copy,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),

                                  /// HD
                                  if (!scale)
                                    SplashCircularIcon(
                                      padding: halfPadding,
                                      onTap: () => controller.quality(),
                                      child: const Icon(
                                        Iconsax.setting_copy,
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
              visible: overlayVisible,
              child: Center(
                child: CenterPlayAndPause(
                  type: CenterPlayAndPauseType.center,
                  showForward: showForward,
                  showRewind: showRewind,
                ),
              ),
            ),
          ),
          if (!scale)
            CustomOpacityTransition(
              visible: controller.isShowingSettingsMenu,
              child: const SettingsMenu(),
            ),
        ],
      ),
    );
  }
}
