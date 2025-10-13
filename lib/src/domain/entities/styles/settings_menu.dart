import 'package:flutter/material.dart';
import 'package:animax_player/src/domain/entities/settings_menu_item.dart';

class SettingsMenuStyle {
  /// These are the styles of the settings sales, here you will change the icons and
  /// the language of the texts
  SettingsMenuStyle({
    this.paddingBetweenMainMenuItems = 24,
    this.paddingSecondaryMenuItems = const EdgeInsets.symmetric(vertical: 4),
    this.items,
  });

  /// It is the padding between all the elements of the SettingsMenu
  final double paddingBetweenMainMenuItems;

  ///ADD CUSTOM SECTIONS TO SETTINGS MENU
  final List<SettingsMenuItem>? items;

  final EdgeInsets paddingSecondaryMenuItems;
}
