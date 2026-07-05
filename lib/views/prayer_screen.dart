import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:islamlearning/views/constants/appcolors.dart';
import '../controllers/prayer_controller.dart';
import '../controllers/prayer_reminder_controller.dart';
import 'constants/system_ui_style.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'widgets/banner_ad_widget.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  late final PrayerController _controller;
  late final PrayerReminderController _reminderController;

  // @override
  // void initState() {
  //   super.initState();
  //   SystemUIConfig.applyLightStatusBar();
  //   _controller = Get.put(PrayerController(), permanent: false);
  //   if (!Get.isRegistered<PrayerReminderController>()) {
  //     Get.put(PrayerReminderController());
  //   }
  //   _reminderController = Get.find<PrayerReminderController>();
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _controller.initLocationService();
  //   });
  // }
  @override
  void initState() {
    super.initState();
    SystemUIConfig.applyLightStatusBar();

    // KEY FIX: reuse the permanent controller ExploreScreen may have created
    _controller = Get.isRegistered<PrayerController>()
        ? Get.find<PrayerController>()
        : Get.put(PrayerController(), permanent: true);

    if (!Get.isRegistered<PrayerReminderController>()) {
      Get.put(PrayerReminderController());
    }
    _reminderController = Get.find<PrayerReminderController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initLocationService();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColorThemed(context),
      appBar: AppBar(
        backgroundColor: AppColors.bgColorThemed(context),
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              easy.tr('prayer_times'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: AppColors.appbarText,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              easy.tr('check_prayers'),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: AppColors.greyTextThemed(context),
              ),
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.appbarText),
                const SizedBox(height: 10),
                Text(
                  _controller.loadingStep.value,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: AppColors.appbarText,
                  ),
                ),
              ],
            ),
          );
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // const Spacer(),
                        _buildNextPrayerCard(context),
                        // const Spacer(),
                        _buildPrayerList(context),
                        const SizedBox(height: 16),
                        _buildCongregationInfo(context),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const BannerAdWidget(),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ─── Next Prayer Card ──────────────────────────────────────────────────────

  Widget _buildNextPrayerCard(BuildContext context) {
    return Obx(() => AnimationConfiguration.synchronized(
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.darkMintGreen,
                      AppColors.greenTeal,
                      AppColors.cyanGreen,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.greyBorderThemed(context),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      easy.tr('next_prayer'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: AppColors.whiteText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _controller.nextPrayer.value,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _controller.timeRemaining.value,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/calender.svg',
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              easy.tr('islamic_date'),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.whiteText,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _controller.getHijriDate(),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.whiteText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  // ─── Prayer List ───────────────────────────────────────────────────────────

  Widget _buildPrayerList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        border: Border.all(
          color: AppColors.greyBorderThemed(context).withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Obx(() {
        final checkins = _controller.prayerCheckins;
        final times = _controller.prayerTimes;
        final reached = _controller.reachedPrayers.value;
        return Column(
          children: [
            ...times.asMap().entries.map((entry) {
              final index = entry.key;
              final prayer = entry.value;
              final showCheckbox =
                  prayer.key != null && prayer.key != 'sunrise';
              final isCheckable = showCheckbox && reached.contains(prayer.key);
              final isChecked = isCheckable && (checkins[prayer.key] ?? false);
              final reminderEnabled =
                  showCheckbox ? _getReminderObservable(prayer.key!) : null;
              final onReminderToggle =
                  showCheckbox ? () => _toggleReminder(prayer.key!) : null;
              return _buildPrayerTile(
                context,
                prayer.name,
                _formatTime(prayer.time),
                prayer.icon,
                prayerKey: prayer.key,
                showCheckbox: showCheckbox,
                isCheckable: isCheckable,
                isChecked: isChecked,
                isCurrent: prayer.isCurrent,
                isLast: index == times.length - 1,
                showHeader: index == 0,
                index: index,
                reminderEnabled: reminderEnabled,
                onReminderToggle: onReminderToggle,
              );
            }),
            _buildCompletionSummary(context),
          ],
        );
      }),
    );
  }

  Widget _buildPrayerTile(
    BuildContext context,
    String title,
    String time,
    String svgAsset, {
    required int index,
    String? prayerKey,
    bool showCheckbox = false,
    bool isCheckable = false,
    bool isChecked = false,
    bool isCurrent = false,
    bool isLast = false,
    bool showHeader = false,
    RxBool? reminderEnabled,
    VoidCallback? onReminderToggle,
  }) {
    final isAsrPrayer = prayerKey == 'asr';

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 500),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Column(
            children: [
              if (showHeader) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          easy.tr('prayers'),
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.greyTextThemed(context),
                          ),
                        ),
                      ),
                      Text(
                        easy.tr('time'),
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.greyTextThemed(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: AppColors.greyBorderThemed(context),
                  thickness: 1,
                ),
              ],
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: isChecked
                      ? AppColors.greenTeal.withValues(alpha: 0.06)
                      : isCurrent
                          ? AppColors.containerColorThemed(context)
                          : Colors.transparent,
                  border: Border(
                    bottom: isLast
                        ? BorderSide.none
                        : BorderSide(
                            color: AppColors.greyBorderThemed(context),
                            width: 1,
                          ),
                  ),
                ),
                child: Row(
                  children: [
                    Opacity(
                      opacity: isChecked ? 0.5 : 1.0,
                      child: SvgPicture.asset(svgAsset, height: 20, width: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          Opacity(
                            opacity: isChecked ? 0.5 : 1.0,
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.blackTextThemed(context),
                              ),
                            ),
                          ),
                          if (isAsrPrayer) ...[
                            const SizedBox(width: 8),
                            Obx(() => Container(
                                  height: 24,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.containerColorThemed(context),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color:
                                          AppColors.greyBorderThemed(context),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _controller.asrMethod.value,
                                      isDense: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        size: 16,
                                        color:
                                            AppColors.greyTextThemed(context),
                                      ),
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            AppColors.blackTextThemed(context),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 0, child: Text('Shafi')),
                                        DropdownMenuItem(
                                            value: 1, child: Text('Hanafi')),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          _controller.changeAsrMethod(value);
                                        }
                                      },
                                    ),
                                  ),
                                )),
                          ],
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            if (reminderEnabled != null) ...[
                              Obx(() => Icon(
                                    reminderEnabled.value
                                        ? Icons.notifications
                                        : Icons.notifications_outlined,
                                    size: 16,
                                    color: reminderEnabled.value
                                        ? AppColors.appbarText
                                        : AppColors.greyTextThemed(context),
                                  )),
                              const SizedBox(width: 2),
                              Obx(() => Transform.scale(
                                    scale: 0.75,
                                    alignment: Alignment.centerRight,
                                    child: Switch(
                                      value: reminderEnabled.value,
                                      onChanged: (_) =>
                                          onReminderToggle?.call(),
                                      activeThumbColor: AppColors.appbarText,
                                      activeTrackColor: AppColors.appbarText
                                          .withValues(alpha: 0.3),
                                      inactiveThumbColor:
                                          AppColors.greyTextThemed(context),
                                      inactiveTrackColor:
                                          AppColors.greyBorderThemed(context),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  )),
                              const SizedBox(width: 4),
                            ] else ...[
                              Visibility(
                                visible: false,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: Icon(Icons.notifications_outlined,
                                    size: 16, color: AppColors.appbarText),
                              ),
                              const SizedBox(width: 2),
                              Visibility(
                                visible: false,
                                maintainSize: true,
                                maintainAnimation: true,
                                maintainState: true,
                                child: Transform.scale(
                                  scale: 0.75,
                                  alignment: Alignment.centerRight,
                                  child: Switch(value: true, onChanged: (_) {}),
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],
                            Opacity(
                              opacity: isChecked ? 0.5 : 1.0,
                              child: Text(
                                time,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.blackTextThemed(context),
                                ),
                              ),
                            ),
                            if (showCheckbox) ...[
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: isCheckable
                                    ? () => _controller
                                        .togglePrayerCheckin(prayerKey!)
                                    : null,
                                child: Opacity(
                                  opacity: isCheckable ? 1.0 : 0.35,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isChecked
                                          ? AppColors.greenTeal
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isChecked
                                            ? AppColors.greenTeal
                                            : Colors.grey,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isChecked
                                        ? const Icon(Icons.check,
                                            color: Colors.white, size: 14)
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          ]),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Completion Summary ────────────────────────────────────────────────────

  Widget _buildCompletionSummary(BuildContext context) {
    return Obx(() {
      final count = _controller.completedCount.value;
      final streak = _controller.streakDays.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.appbarText.withValues(alpha: 0.04),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$count / 5 ${easy.tr('prayers_completed')}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.appbarText,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (streak > 0)
              Row(
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$streak ${easy.tr('day_streak')}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }

  // ─── Congregation Info ─────────────────────────────────────────────────────

  Widget _buildCongregationInfo(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.appbarText.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.appbarText.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.appbarText, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              easy.tr('congregation_info'),
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.greyTextThemed(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  RxBool? _getReminderObservable(String key) {
    debugPrint("show toggle click");

    switch (key) {
      case 'fajr':
        return _reminderController.fajrReminder;
      case 'dhuhr':
        return _reminderController.dhuhrReminder;
      case 'asr':
        return _reminderController.asrReminder;
      case 'maghrib':
        return _reminderController.maghribReminder;
      case 'isha':
        return _reminderController.ishaReminder;
      default:
        return null;
    }
  }

  void _toggleReminder(String key) {
    switch (key) {
      case 'fajr':
        _reminderController.toggleFajrReminder();
        break;
      case 'dhuhr':
        _reminderController.toggleDhuhrReminder();
        break;
      case 'asr':
        _reminderController.toggleAsrReminder();
        break;
      case 'maghrib':
        _reminderController.toggleMaghribReminder();
        break;
      case 'isha':
        _reminderController.toggleIshaReminder();
        break;
    }
  }

  String _formatTime(String time) {
    if (time.isEmpty) return time;
    for (final fmt in ['HH:mm', 'H:mm', 'HH:mm:ss', 'h:mm a', 'h:mm']) {
      try {
        return DateFormat('h:mm a').format(DateFormat(fmt).parse(time.trim()));
      } catch (_) {}
    }
    return time;
  }
}
