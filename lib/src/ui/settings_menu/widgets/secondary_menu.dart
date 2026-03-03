import 'package:flutter/material.dart';

class SecondaryMenu extends StatelessWidget {
  const SecondaryMenu({
    super.key,
    required this.children,
    this.width = 150,
  });

  final List<Widget> children;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ),
    );
  }
}