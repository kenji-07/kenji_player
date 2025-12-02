import 'dart:async';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:flutter/material.dart';

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
      iconData =
          type == 0 ? PhosphorIcons.speakerSimpleX() : PhosphorIcons.moon();
    } else if (value < 0.5) {
      iconData =
          type == 0 ? PhosphorIcons.speakerLow() : PhosphorIcons.sunHorizon();
    } else {
      iconData = type == 0 ? PhosphorIcons.speakerHigh() : PhosphorIcons.sun();
    }

    return Align(
      alignment: const Alignment(0, -0.7),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.all(Radius.circular(20.0))),
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
