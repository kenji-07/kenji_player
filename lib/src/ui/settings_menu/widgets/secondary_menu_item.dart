import 'package:flutter/material.dart';
import 'package:animax_player/src/ui/widgets/helpers.dart';

class SecondaryMenuItem extends StatelessWidget {
  const SecondaryMenuItem({
    super.key,
    required this.onTap,
    required this.text,
    required this.selected,
  });

  final VoidCallback onTap;
  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: CustomText(text: text, selected: selected),
      ),
    );
  }
}
