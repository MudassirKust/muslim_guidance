import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Sun mascot clock: static PNG body (spikes, ring, ticks) dynamically
/// tinted per mood, a mood-based emoji image for the face, and
/// live-rotating hands painted in the matching mood color.
class SunMascotClock extends StatefulWidget {
  const SunMascotClock({
    super.key,
    this.size = 200,
    this.mood = ClockMood.sad,
    this.backgroundAsset = 'assets/clock2/Rectangle (1).png',
  });

  final double size;
  final ClockMood mood;
  final String backgroundAsset;

  @override
  State<SunMascotClock> createState() => _SunMascotClockState();
}

enum ClockMood { happy, worried, sad }

extension on ClockMood {
  /// Emoji face asset per mood.
  String get emojiAsset {
    switch (this) {
      case ClockMood.happy:
        return 'assets/clock/emoji.png';
      case ClockMood.worried:
        return 'assets/clock2/emoji.png';
      case ClockMood.sad:
        return 'assets/clock3/emoji.png';
    }
  }

  /// Base tint color per mood — used for both the body tint and the hands.
  Color get color {
    switch (this) {
      case ClockMood.happy:
        return const Color(0xFF4CAF50); // green
      case ClockMood.worried:
        return const Color(0xFFFFB300); // amber
      case ClockMood.sad:
        return const Color(0xFFE53935); // red
    }
  }
}

class _SunMascotClockState extends State<SunMascotClock> {
  DateTime _time = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _time = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodColor = widget.mood.color;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Layer 1: static body, recolored per mood using a tint blend.
          // BlendMode.modulate multiplies the image's existing shading
          // (highlights/shadows) by the tint color, so the 3D look of the
          // gold artwork is preserved instead of flattening to one color.
          Image.asset(
            widget.backgroundAsset,
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
          ),

          // Layer 2: mood emoji face, centered on the clock face.
          Align(
            alignment: const Alignment(0, 0.3),
            child: Image.asset(
              widget.mood.emojiAsset,
              width: widget.size * 0.55,
              fit: BoxFit.contain,
            ),
          ),

          // Layer 3: live-rotating hands + hub, colored to match the mood.
          Positioned.fill(
            child: CustomPaint(
              painter: _HandsPainter(time: _time, moodColor: moodColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _HandsPainter extends CustomPainter {
  _HandsPainter({required this.time, required this.moodColor});

  final DateTime time;
  final Color moodColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    final second = time.second;
    final minute = time.minute;
    final hour = time.hour % 12;

    final secondAngle = (second * 6.0) * math.pi / 180;
    final minuteAngle = (minute * 6.0 + second * 0.1) * math.pi / 180;
    final hourAngle = (hour * 30.0 + minute * 0.5) * math.pi / 180;

    // Hour/minute hands use a slightly darker shade of the mood color
    // for depth; second hand uses the base mood color for contrast.
    final darkShade = HSLColor.fromColor(moodColor)
        .withLightness(
            (HSLColor.fromColor(moodColor).lightness - 0.12).clamp(0.0, 1.0))
        .toColor();

    _drawLeafHand(
      canvas,
      center,
      length: radius * 0.38,
      width: radius * 0.16,
      angle: hourAngle,
      color: darkShade,
    );
    _drawLeafHand(
      canvas,
      center,
      length: radius * 0.50,
      width: radius * 0.14,
      angle: minuteAngle,
      color: moodColor,
    );
    _drawThinHand(
      canvas,
      center,
      length: radius * 0.48,
      angle: secondAngle,
      color: darkShade,
    );

    _drawHub(canvas, center, radius);
  }

  void _drawLeafHand(
    Canvas canvas,
    Offset center, {
    required double length,
    required double width,
    required double angle,
    required Color color,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final paint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 0.08;

    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-width / 2, -length * 0.55, 0, -length)
      ..quadraticBezierTo(width / 2, -length * 0.55, 0, 0)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
    canvas.restore();
  }

  void _drawThinHand(
    Canvas canvas,
    Offset center, {
    required double length,
    required double angle,
    required Color color,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final paint = Paint()
      ..color = color
      ..strokeWidth = length * 0.035
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset.zero, Offset(0, -length), paint);
    canvas.restore();
  }

  void _drawHub(Canvas canvas, Offset center, double radius) {
    final paint = Paint()..color = moodColor;
    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.015;
    final hubR = radius * 0.09;
    canvas.drawCircle(center, hubR, paint);
    canvas.drawCircle(center, hubR, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _HandsPainter oldDelegate) {
    return oldDelegate.time != time || oldDelegate.moodColor != moodColor;
  }
}
