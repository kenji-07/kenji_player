import 'package:flutter/material.dart';

import 'package:animax_player/src/domain/entities/settings_menu_item.dart';
import 'package:animax_player/src/data/repositories/video.dart';
import 'package:animax_player/src/ui/widgets/helpers.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final controller = query.video(context, listen: true);
    final metadata = query.videoMetadata(context, listen: true);

    // Null check нэмэх
    if (controller.video == null) return const SizedBox.shrink();

    final style = metadata.style.settingsStyle;
    final items = style.items;

    final source = controller.source;

    // Source null эсэхийг шалгах
    if (source == null || source.isEmpty) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: [
          /// Нэмэлтүүд
          if (items != null)
            for (int i = 0; i < items.length; i++) ...[
              items[i].themed == null
                  ? SplashCircularIcon(
                      onTap: () => query
                          .video(context)
                          .openSecondarySettingsMenu(i + kDefaultMenus),
                      padding: EdgeInsets.all(
                        style.paddingBetweenMainMenuItems / 2,
                      ),
                      child: items[i].mainMenu,
                    )
                  : MainMenuItem(
                      index: i + kDefaultMenus,
                      icon: items[i].themed!.icon,
                      title: items[i].themed!.title,
                      subtitle: items[i].themed!.subtitle,
                    ),
            ],
        ],
      ),
    );
  }
}

class MainMenuItem extends StatelessWidget {
  const MainMenuItem({
    super.key,
    required this.index,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Widget icon;
  final String title, subtitle;
  final int index;

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final metadata = query.videoMetadata(context, listen: true);

    final style = metadata.style.settingsStyle;
    final textStyle = metadata.style.textStyle;

    // fontSize-г null safety-тэй авах
    final double baseFontSize = textStyle.fontSize ?? 14.0;

    return SplashCircularIcon(
      padding: EdgeInsets.all(style.paddingBetweenMainMenuItems),
      onTap: () => query.video(context).openSecondarySettingsMenu(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          Text(title, style: textStyle),
          Text(
            subtitle,
            style: textStyle.merge(
              TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: baseFontSize - 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
