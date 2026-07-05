import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamlearning/controllers/ad_controller.dart';
import 'package:islamlearning/services/ad_constants.dart';
import 'package:islamlearning/services/ad_service.dart';

class SplashBannerAdController extends GetxController {
  final isAdLoading = false.obs;
  final isAdReady = false.obs;
  final isAdFailed = false.obs;

  BannerAd? bannerAd;

  @override
  void onInit() {
    super.onInit();
    loadBannerAd();
  }

  void loadBannerAd() {
    final adController = Get.find<AdController>();
    final service = AdService.instance;

    if (!adController.bannerEnabled.value || service.isPremiumUser) {
      return;
    }

    if (isAdLoading.value || isAdReady.value) {
      return;
    }

    _loadBanner();
  }

  void _loadBanner() {
    isAdLoading.value = true;
    isAdReady.value = false;
    isAdFailed.value = false;

    bannerAd?.dispose();

    bannerAd = BannerAd(
      adUnitId: kDebugMode
          ? "ca-app-pub-3940256099942544/6300978111"
          : AdConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          isAdLoading.value = false;
          isAdReady.value = true;
          isAdFailed.value = false;

          debugPrint("✅ Splash Banner Loaded");
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          bannerAd = null;

          isAdLoading.value = false;
          isAdReady.value = false;
          isAdFailed.value = true;

          debugPrint("❌ Splash Banner Failed: $error");
        },
      ),
    );

    bannerAd!.load();
  }

  @override
  void onClose() {
    bannerAd?.dispose();
    super.onClose();
  }
}
