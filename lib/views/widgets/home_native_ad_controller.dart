import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamlearning/controllers/ad_controller.dart';
import 'package:islamlearning/services/ad_constants.dart';
import 'package:islamlearning/services/ad_service.dart';

class HomeNativeAdController extends GetxController {
  var isAdLoading = false.obs;
  var isAdFailed = false.obs;
  var isAdReady = false.obs;
  var isAdShow = false.obs;

  NativeAd? nativeAd1;

  @override
  void onInit() {
    super.onInit();
    loadNativeAd();
  }

  void loadNativeAd() {
    final adController = Get.find<AdController>();
    final service = AdService.instance;

    if (!adController.nativeEnabled.value || service.isPremiumUser) return;

    if (isAdLoading.value || isAdReady.value) return;

    _loadNativeAd1();
  }

  void _loadNativeAd1() {
    isAdLoading.value = true;
    isAdFailed.value = false;
    isAdReady.value = false;

    // Dispose old ad if any
    nativeAd1?.dispose();
    nativeAd1 = null;
    isAdShow.value = false;
    nativeAd1 = NativeAd(
      adUnitId: kDebugMode
          ? "ca-app-pub-3940256099942544/2247696110"
          : AdConstants.nativeAdUnitId,
      request: const AdRequest(),
      factoryId: "medium_280",
      // nativeTemplateStyle: NativeTemplateStyle(
      //   mainBackgroundColor: Colors.white,
      //   cornerRadius: 12,
      //   templateType: TemplateType.small,
      // ),

      listener: NativeAdListener(
        onAdLoaded: (ad) {
          isAdLoading.value = false;
          isAdReady.value = true;
          isAdFailed.value = false;
          debugPrint('✅ Native Ad Loaded');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          nativeAd1 = null;
          isAdLoading.value = false;
          isAdReady.value = false;
          isAdFailed.value = true;
          debugPrint('❌ Native Ad Failed: $error');
        },
        onAdImpression: (ad) {
          isAdShow.value = true;
        },
      ),
    );

    nativeAd1!.load();
  }

  @override
  void onClose() {
    nativeAd1?.dispose();
    nativeAd1 = null;
    super.onClose();
  }
}
