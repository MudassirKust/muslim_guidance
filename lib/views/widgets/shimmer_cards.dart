import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PrayerCardsShimmer extends StatelessWidget {
  const PrayerCardsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          _buildStreakCardShimmer(),
          const SizedBox(height: 10),
          _buildHealthCardShimmer(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // ── Streak Card Shimmer ───────────────────────────────────────────────────

  Widget _buildStreakCardShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(width: 200, height: 22),
                    const SizedBox(height: 8),
                    _box(width: 160, height: 14),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Right: fire + days
              Row(
                children: [
                  _box(width: 30, height: 30, radius: 8),
                  const SizedBox(width: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(width: 30, height: 28),
                      const SizedBox(height: 4),
                      _box(width: 30, height: 13),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Prayer timeline row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(5 * 2 - 1, (index) {
              if (index.isOdd) {
                // Connector line
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 22),
                    child: _box(height: 3),
                  ),
                );
              } else {
                // Prayer dot + name
                return Column(
                  children: [
                    _circle(32),
                    const SizedBox(height: 10),
                    _box(width: 36, height: 13),
                  ],
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  // ── Health Card Shimmer ───────────────────────────────────────────────────

  Widget _buildHealthCardShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Top green section
          Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon placeholder
                _circle(90),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(width: 120, height: 22),
                      const SizedBox(height: 6),
                      _box(width: 180, height: 14),
                      const SizedBox(height: 4),
                      _box(width: 140, height: 14),
                      const SizedBox(height: 10),
                      // Badge
                      _box(width: 150, height: 28, radius: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // Bottom white section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(width: 80, height: 13),
                      const SizedBox(height: 6),
                      _box(width: 120, height: 26),
                      const SizedBox(height: 6),
                      _box(width: 180, height: 26),
                    ],
                  ),
                ),
                _box(width: 110, height: 80, radius: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _box({
    double? width,
    double height = 16,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
