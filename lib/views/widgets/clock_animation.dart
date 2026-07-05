import 'dart:math';
import 'package:flutter/material.dart';

/// Simplified custom-painted cactus clock — NO painted-on face.
/// An emoji/sticker image is overlaid separately on top, so you can swap
/// expressions (happy, sleepy, alarm, etc.) without touching the painter.
class SimpleCactusClock extends StatefulWidget {
  final double size;

  /// Path to an emoji/face image asset, e.g. 'assets/emoji/happy.png'.
  /// Pass null to render the clock with no face at all.
  final String? emojiAsset;

  /// How big the emoji is relative to the dial. 0.5 means the emoji's
  /// width equals half the clock's total size.
  final double emojiScale;

  const SimpleCactusClock({
    super.key,
    this.size = 240,
    this.emojiAsset,
    this.emojiScale = 0.42,
  });

  @override
  State<SimpleCactusClock> createState() => _SimpleCactusClockState();
}

class _SimpleCactusClockState extends State<SimpleCactusClock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                painter: _CactusClockPainter(now: DateTime.now()),
                size: Size.square(widget.size),
              ),
              if (widget.emojiAsset != null)
                // Sits slightly above true center so it doesn't get
                // covered by the hands, matching the reference art where
                // the face/sticker sits in the upper-middle of the dial.
                Transform.translate(
                  offset: Offset(0, -widget.size * 0.04),
                  child: Image.asset(
                    widget.emojiAsset!,
                    width: widget.size * widget.emojiScale,
                    height: widget.size * widget.emojiScale,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CactusClockPainter extends CustomPainter {
  final DateTime now;

  _CactusClockPainter({required this.now});

  static const Color spikeFill = Color(0xFF6FBB55);
  static const Color spikeShade = Color(0xFF59A642);
  static const Color spikeBorder = Color(0xFF3C7530);
  static const Color ringOuter = Color(0xFF3C7530);
  static const Color ringMid = Color(0xFF8AD06E);
  static const Color dialColor = Color(0xFFE3F4D8);
  static const Color tickColor = Color(0xFF6FBB55);
  static const Color handColor = Color(0xFF3C7530);
  static const Color handHighlight = Color(0xFF4F9540);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    _drawSpikes(canvas, center, radius);
    _drawRings(canvas, center, radius);
    _drawTicks(canvas, center, radius);
    _drawHands(canvas, center, radius);
    _drawPivot(canvas, center, radius);
  }

  void _drawSpikes(Canvas canvas, Offset center, double radius) {
    final fillPaint = Paint()..color = spikeFill;
    final shadePaint = Paint()..color = spikeShade;
    final borderPaint = Paint()
      ..color = spikeBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.012
      ..strokeJoin = StrokeJoin.round;

    const spikeCount = 12;
    final innerR = radius * 0.70;
    final outerR = radius * 1.0;
    const halfWidthDeg = 13.0;
    // How far back from the true tip the rounding starts — keeps the
    // spike pointed overall while softening just the very corner, like
    // the reference artwork (no razor-sharp tips).
    const tipRoundDeg = 2.4;

    for (int i = 0; i < spikeCount; i++) {
      final angle = (i / spikeCount) * 2 * pi;
      final tip = Offset(
        center.dx + outerR * sin(angle),
        center.dy - outerR * cos(angle),
      );
      final baseA = angle - (halfWidthDeg * pi / 180);
      final baseB = angle + (halfWidthDeg * pi / 180);
      final p1 = Offset(
        center.dx + innerR * sin(baseA),
        center.dy - innerR * cos(baseA),
      );
      final p2 = Offset(
        center.dx + innerR * sin(baseB),
        center.dy - innerR * cos(baseB),
      );
      final midBase = Offset(
        center.dx + innerR * 0.97 * sin(angle),
        center.dy - innerR * 0.97 * cos(angle),
      );

      // Two points just shy of the tip on either side, slightly pulled
      // inward, used as control anchors so the very corner gets rounded
      // off instead of meeting in a sharp point.
      final tipShoulderR = outerR * 0.965;
      final tipA = angle - (tipRoundDeg * pi / 180);
      final tipB = angle + (tipRoundDeg * pi / 180);
      final tipShoulder1 = Offset(
        center.dx + tipShoulderR * sin(tipA),
        center.dy - tipShoulderR * cos(tipA),
      );
      final tipShoulder2 = Offset(
        center.dx + tipShoulderR * sin(tipB),
        center.dy - tipShoulderR * cos(tipB),
      );

      final path = Path()
        ..moveTo(p1.dx, p1.dy)
        ..quadraticBezierTo(
            midBase.dx, midBase.dy, tipShoulder1.dx, tipShoulder1.dy)
        ..quadraticBezierTo(tip.dx, tip.dy, tipShoulder2.dx, tipShoulder2.dy)
        ..quadraticBezierTo(midBase.dx, midBase.dy, p2.dx, p2.dy)
        ..close();

      canvas.drawPath(path, fillPaint);
      final shadePath = Path()
        ..moveTo(midBase.dx, midBase.dy)
        ..quadraticBezierTo(tip.dx, tip.dy, tipShoulder2.dx, tipShoulder2.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();
      canvas.drawPath(shadePath, shadePaint);
      canvas.drawPath(path, borderPaint);
    }
  }

  void _drawRings(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius * 0.70, Paint()..color = ringOuter);
    canvas.drawCircle(center, radius * 0.63, Paint()..color = ringMid);
    canvas.drawCircle(center, radius * 0.57, Paint()..color = dialColor);
  }

  void _drawTicks(Canvas canvas, Offset center, double radius) {
    final paint = Paint()..color = tickColor;
    final ovalW = radius * 0.045;
    final ovalH = radius * 0.09;

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi;
      final r = radius * 0.50;
      final pos = Offset(
        center.dx + r * sin(angle),
        center.dy - r * cos(angle),
      );

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: ovalW, height: ovalH),
          Radius.circular(ovalW / 2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  void _drawHands(Canvas canvas, Offset center, double radius) {
    final hour = now.hour % 12;
    final minute = now.minute;
    final second = now.second;
    final millis = now.millisecond;

    final secondsFraction = (second + millis / 1000) / 60;
    final minuteAngle = ((minute + secondsFraction) / 60) * 2 * pi;
    final hourAngle = ((hour + minute / 60) / 12) * 2 * pi;

    _drawLeafHand(
      canvas,
      center,
      angle: hourAngle,
      length: radius * 0.34,
      maxWidth: radius * 0.13,
    );
    _drawLeafHand(
      canvas,
      center,
      angle: minuteAngle,
      length: radius * 0.46,
      maxWidth: radius * 0.10,
    );
  }

  void _drawLeafHand(
    Canvas canvas,
    Offset center, {
    required double angle,
    required double length,
    required double maxWidth,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final tipY = -length;
    final bulgeY = -length * 0.62;
    final baseY = -length * 0.12;

    final path = Path()
      ..moveTo(0, baseY)
      ..quadraticBezierTo(-maxWidth * 0.5, bulgeY, 0, tipY)
      ..quadraticBezierTo(maxWidth * 0.5, bulgeY, 0, baseY)
      ..close();

    canvas.drawPath(path, Paint()..color = handColor);

    final highlight = Path()
      ..moveTo(0, baseY)
      ..quadraticBezierTo(-maxWidth * 0.12, bulgeY, 0, tipY);
    canvas.drawPath(
      highlight,
      Paint()
        ..color = handHighlight
        ..style = PaintingStyle.stroke
        ..strokeWidth = maxWidth * 0.08
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  void _drawPivot(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius * 0.075, Paint()..color = handColor);
    canvas.drawCircle(
      center,
      radius * 0.075,
      Paint()
        ..color = ringOuter
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.012,
    );
    canvas.drawCircle(
      center,
      radius * 0.032,
      Paint()..color = handHighlight,
    );
  }

  @override
  bool shouldRepaint(covariant _CactusClockPainter oldDelegate) => true;
}
