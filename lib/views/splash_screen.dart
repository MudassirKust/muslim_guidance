import 'dart:async';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamlearning/views/constants/appcolors.dart';
import 'package:islamlearning/views/constants/appimages.dart';
import 'package:islamlearning/views/language_screen.dart';
import 'package:islamlearning/services/app_review_service.dart';
import 'package:islamlearning/services/ad_service.dart';
import 'package:islamlearning/services/local_manager.dart';
import 'package:islamlearning/views/nav_screen.dart';
import 'package:islamlearning/views/widgets/language_ads_controller.dart';
import 'package:islamlearning/views/widgets/onboard_ads_controller.dart';
import 'package:islamlearning/views/widgets/splash_banner_ad_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  /// Navigate to home after splash delay. Location permission is requested on home screen.
  void _navigateToHome() async {
    // Ad is already loading from AdService.initialize() — just wait for the splash delay.
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final completed = await LocaleManager.isOnboardingCompleted();
    if (!mounted) return;

    if (!completed) {
      Get.put(LanguageAdsController(), permanent: true);
      Get.put(OnboardAdsController(), permanent: true);

      // First launch: show interstitial before the language screen.
      await AdService.instance.showSplashInterstitialIfReady(timeoutSeconds: 5);
      await Future.delayed(Duration(seconds: 1), () {});

      if (!mounted) return;

      Get.off(() => const LanguageScreen(
            isOnboarding: true,
            isOnboardComplete: false,
          ));
      return;
    }

    // showAppOpenAdIfReady waits up to 3s for the ad load to complete.
    await AdService.instance.showAppOpenAdIfReady();
    if (!mounted) return;
    await Future.delayed(Duration(seconds: 1), () {});
    Get.off(() => NavScreen());
    AppReviewService.logHomeLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor(context),
      body: Stack(
        children: [
          Center(
            child: AnimationLimiter(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 500),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 40.0,
                    child: FadeInAnimation(child: widget),
                  ),
                  children: [
                    Image.asset(
                      AppImages.appIconPNG,
                      width: 150,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      easy.tr('app_name'),
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blackText(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: SafeArea(
              child: Center(
                child: SplashBannerAdWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
