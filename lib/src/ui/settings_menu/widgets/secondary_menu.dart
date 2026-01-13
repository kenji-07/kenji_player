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
      child: Container(
        width: width,
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
              ]
            ],
          ),
        ),
      ),
    );
  }
}
