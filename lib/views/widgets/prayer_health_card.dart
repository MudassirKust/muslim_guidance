import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:islamlearning/views/widgets/clock2.dart';

enum PrayerHealthStatus { good, hurryUp, prioritize }

class PrayerHealthCard extends StatelessWidget {
  final PrayerHealthStatus status;
  final String nextPrayerName;
  final RxString timeRemainingObservable;
  final String lastUpdated;

  const PrayerHealthCard({
    super.key,
    required this.status,
    required this.nextPrayerName,
    required this.timeRemainingObservable,
    this.lastUpdated = 'Just now',
  });

  _StatusConfig get _config {
    switch (status) {
      case PrayerHealthStatus.good:
        return _StatusConfig(
          iconAsset: 'assets/home/good_job_icon.png',
          title: easy.tr('great_job'),
          titleColor: const Color(0xFF6FCF97),
          subtitle: easy.tr('great_job_thanks'),
          description: easy.tr('great_job_title'),
          bgTopColor: const Color(0xFF2D6A5A),
        );
      case PrayerHealthStatus.hurryUp:
        return _StatusConfig(
          iconAsset: 'assets/home/hurry_up_icon.png',
          title: easy.tr('hurry_up'),
          titleColor: const Color(0xFFF5C842),
          subtitle: easy.tr('hurry_up_title'),
          description: easy.tr('hurry_up_desp'),
          bgTopColor: const Color(0xFF2D6A5A),
        );
      case PrayerHealthStatus.prioritize:
        return _StatusConfig(
          iconAsset: 'assets/home/prioritize_icon.png',
          title: easy.tr('prioritize_prayer'),
          titleColor: const Color(0xFFFF6B6B),
          subtitle: easy.tr('prioritize_prayer_title'),
          description: easy.tr('prioritize_prayer_desp'),
          bgTopColor: const Color(0xFF2D6A5A),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top section ───────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
            decoration: BoxDecoration(
              color: config.bgTopColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Image.asset(
                //   config.iconAsset,
                //   width: 90,
                //   height: 90,
                // ),
                if (config.title == easy.tr('great_job')) ...[
                  const SunMascotClock(
                    size: 120,
                    mood: ClockMood.happy,
                    backgroundAsset: 'assets/clock/clock_face.png',
                  ),
                ] else if (config.title == easy.tr('hurry_up')) ...[
                  const SunMascotClock(
                    size: 120,
                    mood: ClockMood.worried,
                    backgroundAsset: 'assets/clock2/Rectangle (1).png',
                  ),
                ] else ...[
                  const SunMascotClock(
                    size: 120,
                    mood: ClockMood.sad,
                    backgroundAsset: 'assets/clock3/Rectangle (3).png',
                  ),
                ],
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.title,
                        style: TextStyle(
                          color: config.titleColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        config.subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        config.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${easy.tr('latest_update')}: $lastUpdated',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom section ────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        easy.tr('next_pray'),
                        style: TextStyle(
                          color: Color(0xFF2D9B7A),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        nextPrayerName,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Obx reads the live RxString from PrayerController
                      Obx(() => RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${easy.tr('in')} ",
                                  style: TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: timeRemainingObservable.value,
                                  style: const TextStyle(
                                    color: Color(0xff268E6E),
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/home/masjid_icon.png',
                  width: 110,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusConfig {
  final String iconAsset;
  final String title;
  final Color titleColor;
  final String subtitle;
  final String description;
  final Color bgTopColor;

  const _StatusConfig({
    required this.iconAsset,
    required this.title,
    required this.titleColor,
    required this.subtitle,
    required this.description,
    required this.bgTopColor,
  });
}

// Thresholds (in minutes) driving the health status transitions.
const int _hurryUpThresholdMinutes = 75; // grace period after prayer time
const int _prioritizeThresholdMinutes = 75 + 45; // 120 min total

/// Status for a SINGLE prayer, based on whether it was prayed and how late.
PrayerHealthStatus getPrayerHealthStatus({
  required DateTime prayerTime,
  required bool isPrayed,
}) {
  if (isPrayed) return PrayerHealthStatus.good;

  final minutesLate = DateTime.now().difference(prayerTime).inMinutes;

  if (minutesLate < _hurryUpThresholdMinutes) {
    return PrayerHealthStatus.good; // still within grace period
  } else if (minutesLate < _prioritizeThresholdMinutes) {
    return PrayerHealthStatus.hurryUp;
  } else {
    return PrayerHealthStatus.prioritize;
  }
}

/// Severity ranking used to find the WORST status across all prayers.
int prayerHealthSeverity(PrayerHealthStatus status) {
  switch (status) {
    case PrayerHealthStatus.good:
      return 0;
    case PrayerHealthStatus.hurryUp:
      return 1;
    case PrayerHealthStatus.prioritize:
      return 2;
  }
}
// PrayerHealthStatus getPrayerHealthStatus({
//   required DateTime prayerTime,
//   required DateTime? prayedAt,
//   required DateTime windowEnd,
// }) {
//   final now = DateTime.now();
//   if (prayedAt != null) {
//     final lateBy = prayedAt.difference(prayerTime);
//     return lateBy.inMinutes <= 60
//         ? PrayerHealthStatus.good
//         : PrayerHealthStatus.hurryUp;
//   }
//   if (now.isBefore(prayerTime.add(const Duration(hours: 1)))) {
//     return PrayerHealthStatus.hurryUp;
//   }
//   return PrayerHealthStatus.prioritize;
// }
