import 'package:flutter/material.dart';
import 'package:kenji_player/src/data/repositories/video.dart';
import 'package:kenji_player/src/ui/settings_menu/widgets/secondary_menu.dart';
import 'package:kenji_player/src/ui/settings_menu/widgets/secondary_menu_item.dart';

class AspectMenu extends StatelessWidget {
  const AspectMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final controller = query.video(context, listen: true);

    final List<BoxFit> configKeys = [
      BoxFit.cover,
      BoxFit.contain,
      BoxFit.fill,
      BoxFit.fitWidth,
      BoxFit.fitHeight,
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 10, top: 20, bottom: 20),
      child: SecondaryMenu(
        children: [
          for (var fit in configKeys)
            SecondaryMenuItem(
              onTap: () {
                final video = query.video(context);
                video.setAspect(
                  fit,
                );
              },
              text: fit.toString().split('.').last,
              selected: controller.currentAspect == fit,
            ),
        ],
      ),
    );
  }
}
