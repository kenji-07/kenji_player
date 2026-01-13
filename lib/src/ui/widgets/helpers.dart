import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_storage/get_storage.dart';

class SplashCircularIcon extends StatelessWidget {
  const SplashCircularIcon({
    super.key,
    required this.child,
    required this.onTap,
    this.padding = EdgeInsets.zero,
  });

  final Widget? child;
  final void Function() onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Ink(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  const CustomText({
    super.key,
    required this.text,
    required this.selected,
  });

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: selected
                  ? Text(
                      text,
                      style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                    ),
            ),
            if (selected)
              Icon(PhosphorIcons.waveform(), size: 20, color: Colors.red),
          ]),
    );
  }
}

class CustomInkWell extends StatelessWidget {
  const CustomInkWell({
    super.key,
    required this.child,
    required this.onTap,
  });

  final Widget child;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }
}

class Utils {
  static Future<void> launchURL(String? url) async {
    if (url != null && await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // URL нээх боломжгүй бол үйлдэл
      // Toast.error("Could not launch $url");
      print('Could not launch $url');
    }
  }

  static Future<void> setString({
    required String key,
    required String value,
  }) async {
    final GetStorage storage = GetStorage();
    print('${value.runtimeType} - $key - $value');
    await storage.write(key, value);
  }

  /// Retrieve a String value with a default
  static String getString({required String key, String defaultValue = ''}) {
    final GetStorage storage = GetStorage();
    return storage.read<String>(key) ?? defaultValue;
  }
}
