import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/ad_service.dart';
import '../services/local_manager.dart';
import 'auth_controller.dart';
import 'subscription_controller.dart';

class AdController extends GetxController with WidgetsBindingObserver {
  final RxBool bannerEnabled = true.obs;
  final RxBool nativeEnabled = true.obs;
  final RxBool interstitialEnabled = true.obs;
  final RxBool isPremium = false.obs;

  @override
  void onInit() {
    super.onInit();
    _syncFromService();
    _observePremiumStatus();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _maybeShowAppOpenAd();
    }
  }

  Future<void> _maybeShowAppOpenAd() async {
    // Never show App Open during onboarding — it would stack on top of the
    // splash interstitial shown on first launch.
    final onboardingDone = await LocaleManager.isOnboardingCompleted();
    if (!onboardingDone) return;
    // Give the ad up to 5s to load on resume (network may be slower after background)
    AdService.instance.showAppOpenAdIfReady(timeoutSeconds: 5);
  }

  void _syncFromService() {
    bannerEnabled.value = AdService.instance.bannerEnabled;
    nativeEnabled.value = AdService.instance.nativeEnabled;
    interstitialEnabled.value = AdService.instance.interstitialEnabled;
  }

  void _observePremiumStatus() {
    final authController = Get.find<AuthController>();
    final subController = Get.find<SubscriptionController>();

    // Re-evaluate whenever either source changes.
    ever(authController.subscription, (_) {
      _applyPremiumAdPolicy(authController.isPremium);
    });
    ever(subController.customerInfo, (_) {
      _applyPremiumAdPolicy(authController.isPremium);
    });

    _applyPremiumAdPolicy(authController.isPremium);
  }

  void _applyPremiumAdPolicy(bool isPremiumUser) {
    AdService.instance.isPremiumUser = isPremiumUser;
    isPremium.value = isPremiumUser;
    if (isPremiumUser) {
      bannerEnabled.value = false;
      nativeEnabled.value = false;
      interstitialEnabled.value = false;
    } else {
      _syncFromService();
    }
  }
}
