import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamlearning/controllers/ad_controller.dart';
import 'package:islamlearning/services/ad_constants.dart';
import 'package:islamlearning/services/ad_service.dart';

class LanguageAdsController extends GetxController {
  // Observables
  var isFirstAdLoaded = false.obs;
  var isSecondAdLoaded = false.obs;
  var showSecondAdOnly = false.obs;

  NativeAd? nativeAd1;
  NativeAd? nativeAd2;

  final String adUnitId = "ca-app-pub-3940256099942544/2247696110"; // Test ID

  @override
  void onInit() {
    super.onInit();
    loadBothNativeAds();
  }

  void loadBothNativeAds() {
    _loadNativeAd1();
    _loadNativeAd2();
  }

  void _loadNativeAd1() {
    final adController = Get.find<AdController>();
    final AdService service = AdService.instance;
    if (!adController.nativeEnabled.value || service.isPremiumUser) return;

    nativeAd1 = NativeAd(
      adUnitId: kDebugMode
          ? "ca-app-pub-3940256099942544/2247696110"
          : AdConstants.nativeAdUnitId,
      factoryId: "medium_280",
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          isFirstAdLoaded.value = true;
          debugPrint('✅ Native Ad 1 Loaded');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Native Ad 1 Failed: $error');
          ad.dispose();
        },
      ),
    );
    nativeAd1!.load();
  }

  void _loadNativeAd2() {
    final adController = Get.find<AdController>();
    final AdService service = AdService.instance;
    if (!adController.nativeEnabled.value || service.isPremiumUser) return;
    nativeAd2 = NativeAd(
      adUnitId: kDebugMode
          ? "ca-app-pub-3940256099942544/2247696110"
          : Platform.isAndroid
              ? AdConstants.nativeLanguageOnboardAdUnitId
              : AdConstants.nativeAdUnitId,
      request: const AdRequest(),
      factoryId: "medium_280",
      listener: NativeAdListener(
        onAdLoaded: (_) {
          isSecondAdLoaded.value = true;
          debugPrint('✅ Native Ad 2 Loaded');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Native Ad 2 Failed: $error');
          ad.dispose();
        },
      ),
    );
    nativeAd2!.load();
  }

  void showSecondAd() {
    isFirstAdLoaded.value = false; // Hide first ad
    Future.delayed(Duration(milliseconds: 100), () {
      showSecondAdOnly.value = true;
      update();
    });
    update();
  }

  @override
  void onClose() {
    nativeAd1?.dispose();
    nativeAd2?.dispose();
    super.onClose();
  }
}
