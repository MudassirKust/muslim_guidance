import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:islamlearning/controllers/ad_controller.dart';
import 'package:islamlearning/services/ad_constants.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamlearning/services/ad_service.dart';
import 'package:islamlearning/views/constants/appcolors.dart';

class OnboardAdsController extends GetxController {
  var isAd1Loaded = false.obs; // page 2 bottom
  var isAd2Loaded = false.obs; // page 3 fullscreen
  var isAd3Loaded = false.obs; // page 4 bottom

  NativeAd? nativeAd1;
  NativeAd? nativeAdFullscreen;
  NativeAd? nativeAd3;

  static const String _testId = "ca-app-pub-3940256099942544/2247696110";

  @override
  void onInit() {
    super.onInit();
    _loadAd1();
    _loadAdFullscreen();
    _loadAd3();
  }

  NativeTemplateStyle _style({
    required Color ctaColor,
    TemplateType type = TemplateType.medium,
  }) =>
      NativeTemplateStyle(
        templateType: type,
        mainBackgroundColor: Colors.white,
        cornerRadius: 12,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: AppColors.appbarText,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black87,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
      );

  void _loadAd1() {
    final adController = Get.find<AdController>();
    final AdService service = AdService.instance;
    if (!adController.nativeEnabled.value || service.isPremiumUser) return;
    nativeAd1 = NativeAd(
      adUnitId: kDebugMode ? _testId : AdConstants.nativeAdUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: _style(ctaColor: Colors.green),
      listener: NativeAdListener(
        onAdLoaded: (_) => isAd1Loaded.value = true,
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad1 failed: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadAdFullscreen() {
    final adController = Get.find<AdController>();
    final AdService service = AdService.instance;
    if (!adController.nativeEnabled.value || service.isPremiumUser) return;

    nativeAdFullscreen = NativeAd(
      adUnitId: kDebugMode ? _testId : AdConstants.nativeAdUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 12,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: AppColors.appbarText,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black87,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black54,
          style: NativeTemplateFontStyle.normal,
          size: 12,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black45,
          style: NativeTemplateFontStyle.normal,
          size: 11,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (_) => isAd2Loaded.value = true,
        onAdFailedToLoad: (ad, error) {
          debugPrint('AdFullscreen failed: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  // void _loadAdFullscreen() {
  //   nativeAdFullscreen = NativeAd(
  //     adUnitId: kDebugMode ? _testId : AdConstants.nativeAdUnitId,
  //     request: const AdRequest(),
  //     nativeTemplateStyle: NativeTemplateStyle(
  //       templateType:
  //           TemplateType.medium, // medium is the only one that shows image
  //       mainBackgroundColor: Colors.transparent, // let our container color show
  //       cornerRadius: 0, // no rounding — fullscreen
  //       callToActionTextStyle: NativeTemplateTextStyle(
  //         textColor: Colors.white,
  //         backgroundColor: Colors.green,
  //         style: NativeTemplateFontStyle.bold,
  //         size: 16,
  //       ),
  //       primaryTextStyle: NativeTemplateTextStyle(
  //         textColor: Colors.black87,
  //         style: NativeTemplateFontStyle.bold,
  //         size: 15,
  //       ),
  //     ),
  //     listener: NativeAdListener(
  //       onAdLoaded: (_) => isAd2Loaded.value = true,
  //       onAdFailedToLoad: (ad, error) {
  //         debugPrint('AdFullscreen failed: $error');
  //         ad.dispose();
  //       },
  //     ),
  //   )..load();
  // }

  void _loadAd3() {
    final adController = Get.find<AdController>();
    final AdService service = AdService.instance;
    if (!adController.nativeEnabled.value || service.isPremiumUser) return;
    nativeAd3 = NativeAd(
      adUnitId:
          kDebugMode ? _testId : AdConstants.nativeLanguageOnboardAdUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: _style(ctaColor: Colors.deepOrange),
      listener: NativeAdListener(
        onAdLoaded: (_) => isAd3Loaded.value = true,
        onAdFailedToLoad: (ad, error) {
          debugPrint('Ad3 failed: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void onClose() {
    nativeAd1?.dispose();
    nativeAdFullscreen?.dispose();
    nativeAd3?.dispose();
    super.onClose();
  }
}
