import 'package:flutter/material.dart';
import 'package:animax_player/src/data/repositories/video.dart';
import 'package:animate_do/animate_do.dart';

enum RippleSide { left, right }

class ForwardAndRewindRippleSide extends StatelessWidget {
  const ForwardAndRewindRippleSide({
    super.key,
    required this.side,
    required this.text,
  });

  final RippleSide side;
  final String text;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoStyle(context);

    return Padding(
      padding: side == RippleSide.left
          ? const EdgeInsets.only(right: 10)
          : const EdgeInsets.only(left: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          side == RippleSide.left
              ? FadeInRight(
                  animate: true,
                  from: 80,
                  duration: const Duration(milliseconds: 300),
                  child: style.forwardAndRewindStyle.rewind,
                )
              : FadeInLeft(
                  animate: true,
                  from: 80,
                  duration: const Duration(milliseconds: 300),
                  child: style.forwardAndRewindStyle.forward,
                ),
          side == RippleSide.left
              ? FadeInRight(
                  animate: true,
                  from: 80,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : FadeInLeft(
                  animate: true,
                  from: 80,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class RippleLeftPainter extends CustomPainter {
  RippleLeftPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..arcTo(
          Offset(size.width * 0.75, 0.0) & Size(size.width / 4, size.height),
          -1.5,
          3,
          false,
        )
        ..lineTo(0.0, size.height)
        ..lineTo(0.0, 0.0),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class RippleRightPainter extends CustomPainter {
  RippleRightPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path()
        ..arcTo(
          Offset.zero & Size(size.width / 4, size.height),
          -1.5,
          -3.3,
          false,
        )
        ..lineTo(size.width, size.height)
        ..lineTo(size.width, 0.0),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
