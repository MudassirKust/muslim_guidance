import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'dart:math' as math;

enum PrayerStatus { completed, missed, pending, disabled }

class PrayerStreakCard extends StatelessWidget {
  final int streakDays;
  final List<PrayerItem> prayers;

  const PrayerStreakCard({
    super.key,
    required this.streakDays,
    required this.prayers,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F7363), Color(0xFF255B4E)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF255B4E).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      easy.tr('daily_streak'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      easy.tr('stay_consist'),
                      style: TextStyle(
                        color: Color(0xFFAFD3C8),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 30)),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$streakDays',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      Text(
                        streakDays <= 1 ? easy.tr('day') : easy.tr('days'),
                        style: TextStyle(
                          color: Color(0xFFAFD3C8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          _PrayerTimeline(prayers: prayers),
        ],
      ),
    );
  }
}

class _PrayerTimeline extends StatelessWidget {
  final List<PrayerItem> prayers;

  const _PrayerTimeline({required this.prayers});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(prayers.length * 2 - 1, (index) {
        if (index.isOdd) {
          final leftIndex = index ~/ 2;
          final isActive =
              prayers[leftIndex].status == PrayerStatus.completed &&
                  prayers[leftIndex + 1].status != PrayerStatus.disabled;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF63D1AC)
                      : const Color(0xFF3D7A6A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        } else {
          final prayerIndex = index ~/ 2;
          return _PrayerDot(item: prayers[prayerIndex]);
        }
      }),
    );
  }
}

class _PrayerDot extends StatelessWidget {
  final PrayerItem item;

  const _PrayerDot({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDotIcon(),
        const SizedBox(height: 10),
        Text(
          item.name,
          style: TextStyle(
            color: item.status == PrayerStatus.disabled
                ? const Color(0xFF4D8C7B)
                : const Color(0xFFCFE8E0),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDotIcon() {
    switch (item.status) {
      case PrayerStatus.completed:
        return _GlowCircle(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6FE0BB), Color(0xFF4BBF98)],
          ),
          shadowColor: const Color(0xFF4BBF98),
          child: const Icon(Icons.check, color: Colors.white, size: 20),
        );

      case PrayerStatus.missed:
        return _GlowCircle(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFC163), Color(0xFFF5A623)],
          ),
          shadowColor: const Color(0xFFF5A623),
          child: const Icon(Icons.priority_high, color: Colors.white, size: 20),
        );

      case PrayerStatus.pending:
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF356E5F),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF42806F), width: 1.5),
          ),
        );

      case PrayerStatus.disabled:
        return ClipPath(
          clipper: _HexagonClipper(),
          child: Container(
            width: 32,
            height: 32,
            color: const Color(0xFF2D5E50),
            alignment: Alignment.center,
            child: const Icon(
              Icons.star_outline_rounded,
              color: Color(0xFF4D8C7B),
              size: 18,
            ),
          ),
        );
    }
  }
}

/// Circle with a soft drop shadow + radial highlight, matching the Figma glow.
class _GlowCircle extends StatelessWidget {
  final Gradient gradient;
  final Color shadowColor;
  final Widget child;

  const _GlowCircle({
    required this.gradient,
    required this.shadowColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: gradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}

class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    final r = w / 2;

    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 180) * (60 * i - 90);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class PrayerItem {
  final String name;
  final PrayerStatus status;

  const PrayerItem({required this.name, required this.status});
}
