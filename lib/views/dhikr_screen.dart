import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'constants/appcolors.dart';
import 'constants/appimages.dart';
import 'dhikr_details.dart';
import 'widgets/animated_button.dart';
import 'widgets/native_ad_widget.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class DhikrScreen extends StatelessWidget {
  const DhikrScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: easy.tr('dhikr'),
                      child: Text(
                        easy.tr('remembrance'),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: AppColors.whiteText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      easy.tr('vital_set'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.whiteText,
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AnimationLimiter(
              child: Column(
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 500),
              childAnimationBuilder: (widget) => SlideAnimation(
                verticalOffset: 40.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDhikrCard(context, AppImages.tasbih, easy.tr('top_10'), () {
                      Get.to(
                        () => DhikrDetailScreen(
                          categoryIndex: 0,
                          categoryTitle: easy.tr('top_10'),
                        ),
                      );
                    }),
                    const SizedBox(
                      width: 15,
                    ),
                    _buildDhikrCard(context,
                        AppImages.dayAndNight, easy.tr('morning_evening'), () {
                      Get.to(
                        () => DhikrDetailScreen(
                          categoryIndex: 1,
                          categoryTitle: easy.tr('morning_evening'),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDhikrCard(context, AppImages.mosque, easy.tr('general'), () {
                      Get.to(
                        () => DhikrDetailScreen(
                          categoryIndex: 2,
                          categoryTitle: easy.tr('general'),
                        ),
                      );
                    }),
                    const SizedBox(
                      width: 15,
                    ),
                    _buildDhikrCard(context, AppImages.night, easy.tr('night_worship'),
                        () {
                      Get.to(
                        () => DhikrDetailScreen(
                          categoryIndex: 3,
                          categoryTitle: easy.tr('night_worship'),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 15),
                const NativeAdWidget(height: 80),
              ],
            ),
          )),
        ));
  }

  Widget _buildDhikrCard(BuildContext context, String iconPath, String title, VoidCallback onTap) {
    return Expanded(
      child: TouchRippleEffect(
        rippleColor: Colors.grey,
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              height: 142,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.containerColorThemed(context),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  SvgPicture.asset(
                    iconPath,
                    height: 54,
                    width: 54,
                  ),
                  const SizedBox(height: 12),
                  Hero(
                    tag: title,
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.blackTextThemed(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 3.5,
              left: 3.5,
              child: SvgPicture.asset(
                AppImages.leftCorner,
                height: 24,
                width: 24,
              ),
            ),
            Positioned(
              bottom: 3.5,
              right: 3.5,
              child: SvgPicture.asset(
                AppImages.rightCorner,
                height: 24,
                width: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
