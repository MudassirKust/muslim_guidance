import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import '../controllers/prayer_reminder_controller.dart';
import 'constants/appcolors.dart';
import 'constants/appimages.dart';
import 'widgets/animated_button.dart';

class PrayerReminderScreen extends StatelessWidget {
  const PrayerReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PrayerReminderController controller = Get.put(PrayerReminderController());
    var radius = BorderRadius.circular(5);

    return Scaffold(
      backgroundColor: AppColors.bgColorThemed(context),
      appBar: AppBar(
        backgroundColor: AppColors.appbarText,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: Row(
          children: [
            ButtonAnimationWidget(
              child: SvgPicture.asset(
                AppImages.backIcon,
                height: 24,
                width: 24,
                colorFilter: ColorFilter.mode(AppColors.whiteText, BlendMode.srcIn),
              ),
              onTap: () => Get.back(),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  easy.tr('prayer_reminders'),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: AppColors.whiteText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  easy.tr('adhan_reminders'),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    color: AppColors.whiteText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AnimationLimiter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 400),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 20.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // Reminder Time Selection
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.containerColorThemed(context),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.greyBorderThemed(context).withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: AppColors.appbarText,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              easy.tr('reminder_time'),
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.appbarText,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Obx(() => Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: controller.reminderTime.value.toDouble(),
                                min: 1,
                                max: 30,
                                divisions: 29,
                                activeColor: AppColors.appbarText,
                                inactiveColor: AppColors.greyBorderThemed(context),
                                onChanged: (value) {
                                  controller.setReminderTime(value.toInt());
                                },
                              ),
                            ),
                            const SizedBox(width: 15),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.appbarText.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.appbarText.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '${controller.reminderTime.value}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.appbarText,
                                ),
                              ),
                            ),
                          ],
                        )),
                        const SizedBox(height: 8),
                        Text(
                          '${controller.reminderTime.value} ${easy.tr('minutes_before')}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.greyTextThemed(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Prayer Reminders
                  Text(
                    'Daily Prayers',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.appbarText,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Fajr Reminder
                  _buildPrayerReminderTile(context,
                    'Fajr',
                    easy.tr('fajr_reminder'),
                    Icons.wb_sunny_outlined,
                    controller.fajrReminder,
                    controller.toggleFajrReminder,
                    radius,
                  ),
                  
                  // Dhuhr Reminder
                  _buildPrayerReminderTile(context,
                    'Dhuhr',
                    easy.tr('dhuhr_reminder'),
                    Icons.wb_sunny,
                    controller.dhuhrReminder,
                    controller.toggleDhuhrReminder,
                    radius,
                  ),
                  
                  // Asr Reminder
                  _buildPrayerReminderTile(context,
                    'Asr',
                    easy.tr('asr_reminder'),
                    Icons.wb_sunny_outlined,
                    controller.asrReminder,
                    controller.toggleAsrReminder,
                    radius,
                  ),
                  
                  // Maghrib Reminder
                  _buildPrayerReminderTile(context,
                    'Maghrib',
                    easy.tr('maghrib_reminder'),
                    Icons.nights_stay_outlined,
                    controller.maghribReminder,
                    controller.toggleMaghribReminder,
                    radius,
                  ),
                  
                  // Isha Reminder
                  _buildPrayerReminderTile(context,
                    'Isha',
                    easy.tr('isha_reminder'),
                    Icons.nights_stay,
                    controller.ishaReminder,
                    controller.toggleIshaReminder,
                    radius,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Info Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.appbarText.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.appbarText.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.appbarText,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Reminders will be sent ${controller.reminderTime.value} minutes before each prayer time based on your location.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.greyTextThemed(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerReminderTile(
    BuildContext context,
    String prayerName,
    String title,
    IconData icon,
    RxBool isEnabled,
    VoidCallback onToggle,
    BorderRadius radius,
  ) {
    return Obx(() => Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: TouchRippleEffect(
        rippleColor: Colors.grey,
        borderRadius: radius,
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.containerColorThemed(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.greyBorderThemed(context).withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isEnabled.value 
                      ? AppColors.appbarText.withValues(alpha: 0.1)
                      : AppColors.greyBorderThemed(context).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isEnabled.value 
                      ? AppColors.appbarText
                      : AppColors.greyTextThemed(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isEnabled.value 
                        ? AppColors.blackTextThemed(context)
                        : AppColors.greyTextThemed(context),
                  ),
                ),
              ),
              Switch(
                value: isEnabled.value,
                onChanged: (value) => onToggle(),
                activeThumbColor: AppColors.appbarText,
                activeTrackColor: AppColors.appbarText.withValues(alpha: 0.3),
                inactiveThumbColor: AppColors.greyTextThemed(context),
                inactiveTrackColor: AppColors.greyBorderThemed(context),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}






