import 'package:flutter/material.dart';
import 'package:animax_player/src/data/repositories/video.dart';
import 'package:animax_player/src/ui/settings_menu/widgets/secondary_menu.dart';
import 'package:animax_player/src/ui/settings_menu/widgets/secondary_menu_item.dart';

class SpeedMenu extends StatelessWidget {
  const SpeedMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);

    final double speed = video.video!.value.playbackSpeed;

    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 10, top: 20, bottom: 20),
      child: SecondaryMenu(
        children: [
          for (double i = 0.5; i <= 2; i += 0.25)
            SecondaryMenuItem(
              onTap: () {
                final video = query.video(context);
                video.video!.setPlaybackSpeed(i);
              },
              text: i == 1.0 ? "1x (Normal)" : "${i}x",
              selected: i == speed,
            ),
        ],
      ),
    );
  }
}
