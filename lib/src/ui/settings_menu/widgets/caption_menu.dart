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
    video.closeAllSecondarySettingsMenus();
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
      child: SecondaryMenu(
        children: [
          CustomInkWell(
            onTap: () => onTap(context, null, none),
            child: CustomText(
              text: none,
              selected: activeCaption == none || activeCaption == null,
            ),
          ),
          for (MapEntry<String, VideoSource> entry in video.source!.entries)
            if (entry.key == activeSourceName && entry.value.subtitle != null)
              for (MapEntry<String, AnimaxPlayerSubtitle> subtitle
                  in entry.value.subtitle!.entries)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SecondaryMenuItem(
                    onTap: () {
                      onTap(context, subtitle.value, subtitle.key);
                    },
                    text: subtitle.key,
                    selected: subtitle.key == activeCaption,
                  ),
                ),
        ],
      ),
    );
  }
}
