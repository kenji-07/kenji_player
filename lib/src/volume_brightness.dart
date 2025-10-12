import 'dart:async';
import 'package:remixicon/remixicon.dart';
import 'package:flutter/material.dart';

/// Default builder generate default FVolToast UI
Widget defaultFVolumeToast(double value, Stream<double> emitter) {
  return _FSliderToast(value, 0, emitter);
}

Widget defaultFBrightnessToast(double value, Stream<double> emitter) {
  return _FSliderToast(value, 1, emitter);
}

class _FSliderToast extends StatefulWidget {
  final Stream<double> emitter;
  final double initial;

  // type 0 volume
  // type 1 screen brightness
  final int type;

  const _FSliderToast(this.initial, this.type, this.emitter);

  @override
  _FSliderToastState createState() => _FSliderToastState();
}

class _FSliderToastState extends State<_FSliderToast> {
  double value = 0;
  StreamSubscription? subs;

  @override
  void initState() {
    super.initState();
    value = widget.initial;
    subs = widget.emitter.listen((v) {
      setState(() {
        value = v;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subs?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    final type = widget.type;
    if (value <= 0) {
      iconData = type == 0 ? Remix.volume_mute_line : Icons.brightness_low;
    } else if (value < 0.5) {
      iconData = type == 0 ? Remix.volume_down_line : Icons.brightness_medium;
    } else {
      iconData = type == 0 ? Remix.volume_up_line : Remix.sun_line;
    }

    return Align(
      alignment: const Alignment(0, -0.7),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              iconData,
              color: Colors.white,
            ),
            Container(
              width: 100,
              height: 5,
              margin: const EdgeInsets.only(left: 8, right: 8),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
