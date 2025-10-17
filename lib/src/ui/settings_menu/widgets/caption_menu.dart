import 'package:flutter/material.dart';

import 'package:animax_player/src/data/repositories/video.dart';
import 'package:animax_player/src/domain/entities/subtitle.dart';
import 'package:animax_player/src/domain/entities/video_source.dart';

import 'package:animax_player/src/ui/settings_menu/widgets/secondary_menu.dart';
import 'package:animax_player/src/ui/settings_menu/widgets/secondary_menu_item.dart';
import 'package:animax_player/src/ui/widgets/helpers.dart';

class CaptionMenu extends StatelessWidget {
  const CaptionMenu({super.key});

  void onTap(
    BuildContext context,
    AnimaxPlayerSubtitle? subtitle,
    String subtitleName,
  ) async {
    final query = VideoQuery();
    final video = query.video(context);

    await video.changeSubtitle(subtitle: subtitle, subtitleName: subtitleName);
  }

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);

    final activeSourceName = video.activeSourceName;
    final activeCaption = video.activeCaption;
    String none = "Орчуулгагүй";

    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 10, top: 20, bottom: 20),
      child: Column(
        children: [
          Expanded(
            child: SecondaryMenu(
              children: [
                CustomInkWell(
                  onTap: () => onTap(context, null, none),
                  child: CustomText(
                    text: none,
                    selected: activeCaption == none || activeCaption == null,
                  ),
                ),
                for (MapEntry<String, VideoSource> entry
                    in video.source!.entries)
                  if (entry.key == activeSourceName &&
                      entry.value.subtitle != null)
                    for (MapEntry<String, AnimaxPlayerSubtitle> subtitle
                        in entry.value.subtitle!.entries)
                      SecondaryMenuItem(
                        onTap: () {
                          onTap(context, subtitle.value, subtitle.key);
                        },
                        text: subtitle.key,
                        selected: subtitle.key == activeCaption,
                      ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Subtitle Size",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 5),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.red,
                    inactiveTrackColor: Colors.grey,
                    thumbColor: Colors.red,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 0.0),
                    trackHeight: 5.0,
                    valueIndicatorColor: Colors.red,
                    valueIndicatorTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Slider(
                    value: video.currentSubtitleSize.toDouble(),
                    min: 10.0,
                    max: 50.0,
                    divisions: 40,
                    label: video.currentSubtitleSize.toStringAsFixed(0),
                    onChanged: (value) {
                      video.setSubtitleSize(value.toInt());
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
