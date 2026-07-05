import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/views/dua_details.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'constants/appcolors.dart';
import 'constants/appimages.dart';
import 'widgets/animated_button.dart';
import 'package:easy_localization/easy_localization.dart' as easy;

class DuaScreen extends StatelessWidget {
  const DuaScreen({super.key});

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
                      tag: easy.tr('dua'),
                      child: Text(
                        easy.tr('title'),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: AppColors.whiteText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      easy.tr('desc'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        color: AppColors.whiteText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimationLimiter(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        _buildDuaCard(context, AppImages.dailyDua, easy.tr('daily'), () {
                          Get.to(() => DuaDetailScreen(
                                categoryKey: 'daily_duas',
                                categoryTitle: easy.tr('daily'),
                              ));
                        }),
                        const SizedBox(
                          width: 15,
                        ),
                        _buildDuaCard(context, AppImages.masjid, easy.tr('masjid'), () {
                          Get.to(() => DuaDetailScreen(
                                categoryKey: 'worship_and_masjid_duas',
                                categoryTitle: easy.tr('masjid'),
                              ));
                        }),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDuaCard(context, AppImages.life, easy.tr('life'), () {
                          Get.to(() => DuaDetailScreen(
                                categoryKey: 'travel_duas',
                                categoryTitle: easy.tr('life'),
                              ));
                        }),
                        const SizedBox(
                          width: 15,
                        ),
                        _buildDuaCard(context, AppImages.moonOut, easy.tr('emotional'),
                            () {
                          Get.to(() => DuaDetailScreen(
                                categoryKey: 'spiritual_duas',
                                categoryTitle: easy.tr('emotional'),
                              ));
                        }),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TouchRippleEffect(
                      rippleColor: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                      onTap: () {
                        Get.to(() => DuaDetailScreen(
                              categoryKey: 'family_duas',
                              categoryTitle: easy.tr('personal'),
                            ));
                      },
                      child: Stack(
                        children: [
                          Container(
                            height: 142,
                            width: MediaQuery.sizeOf(context).width / 2.3,
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
                                  AppImages.personal,
                                  height: 54,
                                  width: 54,
                                ),
                                const SizedBox(height: 12),
                                Hero(
                                  tag: easy.tr('personal'),
                                  child: Text(
                                    easy.tr('personal'),
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
                    )
                  ],
                ),
              )),
            ),
          ),
        ));
  }

  Widget _buildDuaCard(BuildContext context, String iconPath, String title, VoidCallback onTap) {
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
