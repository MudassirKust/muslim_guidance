import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamlearning/controllers/ad_controller.dart';
import 'package:islamlearning/services/ad_constants.dart';
import 'package:islamlearning/services/ad_service.dart';
import 'package:islamlearning/views/constants/appcolors.dart';

class LocationPermissionAdsController extends GetxController {
  // Observables
  var isAdLoading = false.obs;
  var isAdFailed = false.obs;

  NativeAd? nativeAd1;

  final String adUnitId = "ca-app-pub-3940256099942544/2247696110"; // Test ID

  @override
  void onInit() {
    super.onInit();
    loadNativeAd();
  }

  void loadNativeAd() {
    _loadNativeAd1();
  }

  void _loadNativeAd1() {
    final adController = Get.find<AdController>();
    final AdService service = AdService.instance;
    if (!adController.nativeEnabled.value || service.isPremiumUser) return;
    debugPrint('🔄 Loading Native Ad 1');
    isAdFailed.value = false;
    isAdLoading.value = true;
    nativeAd1 = NativeAd(
      adUnitId: kDebugMode
          ? "ca-app-pub-3940256099942544/2247696110"
          : AdConstants.nativeAdUnitId,
      nativeTemplateStyle: NativeTemplateStyle(
        mainBackgroundColor: Colors.white,
        cornerRadius: 12,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: AppColors.appbarText,
        ),
        templateType: TemplateType.medium,
      ),
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          isAdLoading.value = false;
          debugPrint('✅ Native Ad 1 Loaded');
        },
        onAdFailedToLoad: (ad, error) {
          isAdLoading.value = false;
          isAdFailed.value = true;
          debugPrint('❌ Native Ad 1 Failed: $error');
          ad.dispose();
        },
      ),
    );
    nativeAd1!.load();
  }

  @override
  void onClose() {
    nativeAd1?.dispose();
    super.onClose();
  }
}
