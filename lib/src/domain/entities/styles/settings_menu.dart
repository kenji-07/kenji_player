import 'package:flutter/material.dart';
import 'package:animax_player/src/domain/entities/settings_menu_item.dart';
import 'package:remixicon/remixicon.dart';

class SettingsMenuStyle {
  /// These are the styles of the settings sales, here you will change the icons and
  /// the language of the texts
  SettingsMenuStyle({
    Widget? settings,
    Widget? speed,
    Widget? caption,
    Widget? selected,
    Widget? chevron,
    this.paddingBetweenMainMenuItems = 24,
    this.paddingSecondaryMenuItems = const EdgeInsets.symmetric(vertical: 4),
    this.items,
  })  : settings = settings ??
            const Icon(Remix.settings_3_line, color: Colors.white, size: 20),
        caption = caption ??
            const Icon(
              Remix.closed_captioning_line,
              color: Colors.white,
              size: 20,
            ),
        speed = speed ??
            const Icon(Remix.speed_up_line, color: Colors.white, size: 20),
        selected = selected ??
            const Icon(Remix.check_line, color: Colors.white, size: 20),
        chevron =
            chevron ?? const Icon(Remix.arrow_down_s_line, color: Colors.white);

  /// It is the icon that will have the [speed] change option
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Remix.speed, color: Colors.white, size: 20);
  ///```
  final Widget speed;

  /// It is the icon that will have the [caption] change option
  ///
  ///DEFAULT:
  ///```dart
  ///   Icon(Remix.closed_caption_outlined, color: Colors.white, size: 20);
  ///```
  final Widget caption;

  /// It is the chevron or icon that appears to return to the Settings Menu
  /// when you are changing Quality or Speed
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Remix.chevron_left, color: Colors.white);
  ///```
  final Widget chevron;

  /// It is the icon that appears when the current configuration is selected
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Remix.done, color: Colors.white, size: 20);
  ///```
  final Widget selected;

  /// It is the configuration icon that appears in the ProgressBar and also in
  /// the Settings Menu
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Remix.settings_outlined, color: Colors.white, size: 20);
  ///```
  final Widget settings;

  /// It is the padding between all the elements of the SettingsMenu
  final double paddingBetweenMainMenuItems;

  ///ADD CUSTOM SECTIONS TO SETTINGS MENU
  final List<SettingsMenuItem>? items;

  final EdgeInsets paddingSecondaryMenuItems;
}
