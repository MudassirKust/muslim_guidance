import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/controllers/settings_controller.dart';
import 'package:islamlearning/views/constants/appcolors.dart';
import 'package:islamlearning/views/constants/appimages.dart';
import 'package:islamlearning/views/language_screen.dart';
import 'package:islamlearning/views/about_us_screen.dart';
import 'package:islamlearning/views/prayer_reminder_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'widgets/native_ad_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settingsController = Get.put(SettingsController());
    var radius = BorderRadius.circular(5);

    return Scaffold(
        backgroundColor: AppColors.bgColorThemed(context),
        appBar: AppBar(
          backgroundColor: AppColors.bgColorThemed(context),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                easy.tr('setting'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: AppColors.appbarText,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                easy.tr('personalize_deen'),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 12,
                  color: AppColors.greyTextThemed(context),
                ),
              )
            ],
          ),
          scrolledUnderElevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 400),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 20.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    TouchRippleEffect(
                      rippleColor: Colors.grey,
                      borderRadius: radius,
                      onTap: () => Get.to(() => LanguageScreen()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(AppImages.language),
                                const SizedBox(width: 8),
                                Text(
                                  easy.tr('language'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.blackTextThemed(context),
                                  ),
                                ),
                              ],
                            ),
                            SvgPicture.asset(AppImages.settingsArrow)
                          ],
                        ),
                      ),
                    ),
                    Divider(
                        height: 1, color: AppColors.greyBorderThemed(context)),
                    TouchRippleEffect(
                      rippleColor: Colors.grey,
                      borderRadius: radius,
                      onTap: () => Get.to(() => const PrayerReminderScreen()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.notifications_active,
                                  color: AppColors.appbarText,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  easy.tr('prayer_reminders'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.blackTextThemed(context),
                                  ),
                                ),
                              ],
                            ),
                            SvgPicture.asset(AppImages.settingsArrow)
                          ],
                        ),
                      ),
                    ),
                    Divider(
                        height: 1, color: AppColors.greyBorderThemed(context)),
                    TouchRippleEffect(
                      onTap: () => Get.to(() => AboutUsScreen()),
                      rippleColor: Colors.grey,
                      borderRadius: radius,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.appbarText,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  easy.tr('about_us'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.blackTextThemed(context),
                                  ),
                                ),
                              ],
                            ),
                            SvgPicture.asset(AppImages.settingsArrow)
                          ],
                        ),
                      ),
                    ),
                    Divider(
                        height: 1, color: AppColors.greyBorderThemed(context)),
                    TouchRippleEffect(
                      onTap: () =>
                          settingsController.launchContactEmail(context),
                      rippleColor: Colors.grey,
                      borderRadius: radius,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(AppImages.contactUs),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      easy.tr('contact_us'),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            AppColors.blackTextThemed(context),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SvgPicture.asset(AppImages.settingsArrow),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                        height: 1, color: AppColors.greyBorderThemed(context)),
                    const NativeAdWidget(height: 120),
                    const SizedBox(height: 8),
                    TouchRippleEffect(
                      rippleColor: Colors.grey,
                      borderRadius: radius,
                      onTap: () {
                        Share.share(
                          subject: '',
                          'Checkout this Muslim Guidance App: https://play.google.com/store/apps/details?id=com.muslimguidance',
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(AppImages.share),
                                const SizedBox(width: 8),
                                Text(
                                  easy.tr('share_app'),
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.blackTextThemed(context),
                                  ),
                                ),
                              ],
                            ),
                            SvgPicture.asset(AppImages.settingsArrow)
                          ],
                        ),
                      ),
                    ),
                    Divider(
                        height: 1, color: AppColors.greyBorderThemed(context)),
                    Obx(() => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(AppImages.version,
                                      width: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    easy.tr('version'),
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.blackTextThemed(context),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'v${settingsController.appVersion.value}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: AppColors.greyTextThemed(context),
                                ),
                              )
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
