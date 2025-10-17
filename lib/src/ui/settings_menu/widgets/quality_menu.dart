import 'package:flutter/material.dart';
import 'package:animax_player/src/data/repositories/video.dart';
import 'package:animax_player/src/domain/entities/video_source.dart';
import 'package:animax_player/src/ui/settings_menu/widgets/secondary_menu.dart';
import 'package:animax_player/src/ui/settings_menu/widgets/secondary_menu_item.dart';

class QualityMenu extends StatelessWidget {
  const QualityMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // expo launch
    final query = VideoQuery();
    final video = query.video(context, listen: true);

    final activeSourceName = video.activeSourceName;

    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 10, top: 20, bottom: 20),
      child: SecondaryMenu(
        children: [
          for (MapEntry<String, VideoSource> entry in video.source!.entries)
            SecondaryMenuItem(
              onTap: () async {
                final video = query.video(context);
                if (entry.key != activeSourceName) {
                  if (entry.key != activeSourceName) {
                    await video.changeSource(
                        source: entry.value, name: entry.key);
                  }
                }
              },
              text: entry.key,
              selected: entry.key == activeSourceName,
            ),
        ],
      ),
    );
  }
}
