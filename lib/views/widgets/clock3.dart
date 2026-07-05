import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnalogClock3 extends StatefulWidget {
  const AnalogClock3({super.key, this.size = 300});

  final double size;

  @override
  State<AnalogClock3> createState() => _AnalogClock3State();
}

class _AnalogClock3State extends State<AnalogClock3> {
  DateTime _time = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _time = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final second = _time.second;
    final minute = _time.minute;
    final hour = _time.hour % 12;

    final secondAngle = second * 6.0;
    final minuteAngle = minute * 6.0 + second * 0.1;
    final hourAngle = hour * 30.0 + minute * 0.5;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.asset('assets/clock3/Rectangle (3).png',
              width: widget.size, height: widget.size),

          Align(
            alignment: const Alignment(0, 0.1),
            child: Image.asset(
              'assets/clock3/emoji.png',
              width: widget.size * 0.2,
            ),
          ),

          // Hour hand — artwork is drawn pointing toward ~10 o'clock by
          _hand(
            asset: 'assets/clock3/hour_hand.png',
            width: widget.size * 0.09,
            height: widget.size * 0.1,
            pivotAlignment: const Alignment(0.78, 0.55),
            naturalAngleDegrees: 303.6, // angle the art is already drawn at
            angleDegrees: hourAngle,
          ),

          // Minute hand — artwork is drawn pointing toward ~2:30 by default.
          _hand(
            asset: 'assets/clock3/minute_hand.png',
            width: widget.size * 0.1,
            height: widget.size * 0.075,
            pivotAlignment: const Alignment(-0.86, 0.22),
            naturalAngleDegrees: 74.6,
            angleDegrees: minuteAngle,
          ),

          // Second hand — artwork is already drawn pointing almost straight
          _hand(
            asset: 'assets/clock3/second_hand.png',
            width: widget.size * 0.013,
            height: widget.size * 0.13,
            pivotAlignment: const Alignment(-0.03, 0.91),
            naturalAngleDegrees: 0.8,
            angleDegrees: secondAngle,
          ),

          Center(
            child: Image.asset('assets/clock3/hub.png',
                width: widget.size * 0.05, height: widget.size * 0.09),
          ),
        ],
      ),
    );
  }

  /// for the fact the artwork wasn't originally drawn pointing straight up.
  Widget _hand({
    required String asset,
    required double width,
    required double height,
    required Alignment pivotAlignment,
    required double naturalAngleDegrees,
    required double angleDegrees,
  }) {
    final pivotX = (pivotAlignment.x + 1) / 2 * width;
    final pivotY = (pivotAlignment.y + 1) / 2 * height;
    final center = widget.size / 2;

    final rotation = (angleDegrees - naturalAngleDegrees) * math.pi / 180;

    return Positioned(
      left: center - pivotX,
      top: center - pivotY,
      width: width,
      height: height,
      child: Transform.rotate(
        angle: rotation,
        alignment: pivotAlignment,
        child: Image.asset(asset, width: width, height: height),
      ),
    );
  }
}
