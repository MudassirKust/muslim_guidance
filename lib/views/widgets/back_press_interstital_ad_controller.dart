import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamlearning/controllers/ad_controller.dart';
import 'package:islamlearning/services/ad_constants.dart';
import 'package:islamlearning/services/ad_service.dart';

class BackPressInterstitialController extends GetxController {
  var isAdLoading = false.obs;
  var isAdReady = false.obs;
  var isAdFailed = false.obs;

  InterstitialAd? _interstitialAd;

  // Cooldown to avoid showing ad on every back press
  DateTime? _lastShownTime;
  static const _cooldownSeconds = 30;

  void loadAd() {
    final adController = Get.find<AdController>();
    final service = AdService.instance;

    if (!adController.interstitialEnabled.value || service.isPremiumUser) {
      return;
    }
    if (isAdLoading.value || isAdReady.value) return;

    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    isAdLoading.value = true;
    isAdFailed.value = false;
    isAdReady.value = false;

    _interstitialAd?.dispose();
    _interstitialAd = null;

    InterstitialAd.load(
      adUnitId: kDebugMode
          ? 'ca-app-pub-3940256099942544/1033173712'
          : AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          isAdLoading.value = false;
          isAdReady.value = true;
          isAdFailed.value = false;
          debugPrint('✅ BackPress Interstitial Ad Loaded');

          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;
              isAdReady.value = false;
              debugPrint('🔄 BackPress Interstitial dismissed — reloading');
              loadAd(); // preload next
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _interstitialAd = null;
              isAdReady.value = false;
              debugPrint('❌ BackPress Interstitial failed to show: $error');
              loadAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          isAdLoading.value = false;
          isAdReady.value = false;
          isAdFailed.value = true;
          debugPrint('❌ BackPress Interstitial failed to load: $error');
        },
      ),
    );
  }

  /// Call this on back press. Returns true if ad was shown, false otherwise.
  /// If false, caller should proceed with normal back navigation.
  bool showAdOnBackPress() {
    final adController = Get.find<AdController>();
    final service = AdService.instance;

    if (!adController.interstitialEnabled.value || service.isPremiumUser) {
      return false;
    }

    // Cooldown check — don't spam on every back press
    if (_lastShownTime != null) {
      final elapsed = DateTime.now().difference(_lastShownTime!).inSeconds;
      if (elapsed < _cooldownSeconds) {
        debugPrint('⏳ BackPress ad cooldown active ($elapsed s)');
        return false;
      }
    }

    if (!isAdReady.value || _interstitialAd == null) {
      debugPrint('⚠️ BackPress ad not ready');
      loadAd(); // try to preload for next time
      return false;
    }

    _lastShownTime = DateTime.now();
    _interstitialAd!.show();
    return true;
  }

  @override
  void onClose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    super.onClose();
  }
}
