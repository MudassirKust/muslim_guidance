import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/views/hadiths_detail.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'constants/appcolors.dart';
import 'constants/appimages.dart';
import 'widgets/animated_button.dart';

class HadithsScreen extends StatefulWidget {
  const HadithsScreen({super.key});

  @override
  State<HadithsScreen> createState() => _HadithsScreenState();
}

class _HadithsScreenState extends State<HadithsScreen> {
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: easy.tr('hadiths'),
                    child: Text(
                      easy.tr('hadith_studies'),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: AppColors.whiteText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    easy.tr('prominent_collections'),
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
            padding: const EdgeInsets.all(20),
            child: AnimationLimiter(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 500),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HadithCard(
                          1, easy.tr('sahih_bukhari'), easy.tr('bukhari_desc'),
                          () {
                        Get.to(() =>
                            HadithsDetail(tag: 1, bookId: 'sahih_bukhari'));
                      }),
                      const SizedBox(
                        width: 15,
                      ),
                      HadithCard(
                          2, easy.tr('sahih_muslim'), easy.tr('muslim_desc'),
                          () {
                        Get.to(() =>
                            HadithsDetail(tag: 2, bookId: 'sahih_muslim'));
                      }),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HadithCard(
                          3, easy.tr('tirmidhi'), easy.tr('tirmidhi_desc'), () {
                        Get.to(() =>
                            HadithsDetail(tag: 3, bookId: 'sham_il_tirmidhi'));
                      }),
                      const SizedBox(
                        width: 15,
                      ),
                      HadithCard(4, easy.tr('muwatta'), easy.tr('muwatta_desc'),
                          () {
                        Get.to(() =>
                            HadithsDetail(tag: 4, bookId: 'malik_muwatta'));
                      }),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HadithCard(5, easy.tr('fiqh_sunnah'),
                          easy.tr('fiqh_sunnah_desc'), () {
                        Get.to(() =>
                            HadithsDetail(tag: 5, bookId: 'fiqh_us_sunnah'));
                      }),
                      const SizedBox(
                        width: 15,
                      ),
                      HadithCard(
                          6, easy.tr('hadith_qudsi'), easy.tr('qudsi_desc'),
                          () {
                        Get.to(
                            () => HadithsDetail(tag: 6, bookId: 'an_nawawi'));
                      }),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    easy.tr('key_topics'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: AppColors.blackTextThemed(context),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHadithCard(
                          7,
                          easy.tr('hadithonfiqh'), () {
                        Get.to(() =>
                            HadithsDetail(tag: 7, bookId: 'hadith_on_fiqh'));
                      }),
                      const SizedBox(
                        width: 15,
                      ),
                      _buildHadithCard(
                          8,
                          easy.tr('marriage'), () {
                        Get.to(() => HadithsDetail(
                            tag: 8, bookId: 'hadith_on_marriage'));
                      }),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHadithCard(
                          9,
                          easy.tr('gabriel'), () {
                        Get.to(() =>
                            HadithsDetail(tag: 9, bookId: 'hadith_of_gabriel'));
                      }),
                      const SizedBox(
                        width: 15,
                      ),
                      _buildHadithCard(
                          10,
                          easy.tr('hadithdua'), () {
                        Get.to(() =>
                            HadithsDetail(tag: 10, bookId: 'hadith_on_dua'));
                      }),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHadithCard(
                          11,
                          easy.tr('hadith_on_charity'), () {
                        Get.to(() => HadithsDetail(
                            tag: 11, bookId: 'hadith_on_charity'));
                      }),
                      const SizedBox(
                        width: 15,
                      ),
                      _buildHadithCard(
                          12,
                          easy.tr('hadith_on_polygamy'), () {
                        Get.to(() => HadithsDetail(
                            tag: 12, bookId: 'hadith_on_polygamy'));
                      }),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHadithCard(
                          13,
                          easy.tr('hadith_on_herafter'), () {
                        Get.to(() => HadithsDetail(
                            tag: 13, bookId: 'hadith_on_herafter'));
                      }),
                      const SizedBox(
                        width: 15,
                      ),
                      _buildHadithCard(
                          14,
                          easy.tr('hadith_on_sincerity'), () {
                        Get.to(() => HadithsDetail(
                            tag: 14, bookId: 'hadith_on_sincerity'));
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
                      Get.to(() => HadithsDetail(
                          tag: 15, bookId: 'hadith_on_abstinence'));
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
                              //const SizedBox(height: 12),
                              // SvgPicture.asset(
                              //   iconPath,
                              //   height: 54,
                              //   width: 54,
                              // ),
                              //const SizedBox(height: 12),
                              Hero(
                                tag: 15,
                                child: Text(
                                  easy.tr('hadith_on_abstinence'),
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
                ],
              ),
            )),
          ),
        ));
  }

  Widget _buildHadithCard(
      int tag,
      //String iconPath,
      String title,
      VoidCallback onTap) {
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
                  //const SizedBox(height: 12),
                  // SvgPicture.asset(
                  //   iconPath,
                  //   height: 54,
                  //   width: 54,
                  // ),
                  //const SizedBox(height: 12),
                  Hero(
                    tag: tag,
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

  Widget HadithCard(
      int tag, String title, String subtitle, VoidCallback onTap) {
    return Expanded(
      child: TouchRippleEffect(
        rippleColor: Colors.grey,
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.containerColorThemed(context),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: tag,
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
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: AppColors.greyTextThemed(context),
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
