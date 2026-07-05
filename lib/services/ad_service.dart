import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_constants.dart';
import 'meta_consent_service.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  // Remote Config values (with defaults)
  bool interstitialEnabled = true;
  bool bannerEnabled = true;
  bool nativeEnabled = true;
  bool rewardedEnabled = true;
  int screenSwitchThreshold = 3;

  // Set to true when the authenticated user has an active premium subscription.
  // All ad display methods check this flag and skip ads for premium users.
  bool isPremiumUser = false;

  // Nav interstitial
  InterstitialAd? _navInterstitial;
  Completer<void>? _interstitialLoadCompleter;

  // Rewarded ad
  RewardedAd? _rewardedAd;

  // App Open ad
  AppOpenAd? _appOpenAd;
  Completer<void>? _appOpenAdLoadCompleter;
  bool _suppressNextAppOpen = false;

  static const String _lastAppOpenAdKey = 'last_app_open_ad_timestamp';
  static const int _appOpenCooldownMs = 4 * 60 * 60 * 1000; // 4 hours

  bool get isRewardedAdReady => _rewardedAd != null;

  Future<void> initialize() async {
    try {
      await MetaConsentService.initialize();
      await MobileAds.instance.initialize();
      await _fetchRemoteConfig();
      _loadAppOpenAd();
      _loadNavInterstitial();
      _loadRewardedAd();
    } catch (e) {
      debugPrint('AdService.initialize error: $e');
    }
  }

  Future<void> _fetchRemoteConfig() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await remoteConfig.setDefaults({
        'ad_interstitial_enabled': true,
        'ad_banner_enabled': true,
        'ad_native_enabled': true,
        'ad_rewarded_enabled': true,
        'ad_screen_switch_threshold': 3,
      });
      await remoteConfig.fetchAndActivate();

      interstitialEnabled = remoteConfig.getBool('ad_interstitial_enabled');
      bannerEnabled = remoteConfig.getBool('ad_banner_enabled');
      nativeEnabled = remoteConfig.getBool('ad_native_enabled');
      rewardedEnabled = remoteConfig.getBool('ad_rewarded_enabled');
      screenSwitchThreshold = remoteConfig.getInt('ad_screen_switch_threshold');
    } catch (e) {
      debugPrint('AdService._fetchRemoteConfig error (using defaults): $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Nav Interstitial
  // ---------------------------------------------------------------------------

  void _loadNavInterstitial() {
    if (!interstitialEnabled) return;
    if (_interstitialLoadCompleter != null) return; // Already loading
    _interstitialLoadCompleter = Completer<void>();
    try {
      InterstitialAd.load(
        adUnitId: AdConstants.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _navInterstitial = ad;
            _navInterstitial!.fullScreenContentCallback =
                FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _navInterstitial = null;
                _loadNavInterstitial();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _navInterstitial = null;
                _loadNavInterstitial();
              },
            );
            if (!(_interstitialLoadCompleter?.isCompleted ?? true)) {
              _interstitialLoadCompleter!.complete();
            }
            _interstitialLoadCompleter =
                null; // Allow a fresh load to be triggered
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdService: nav interstitial failed to load: $error');
            _navInterstitial = null;
            if (!(_interstitialLoadCompleter?.isCompleted ?? true)) {
              _interstitialLoadCompleter!.complete();
            }
            _interstitialLoadCompleter = null; // Allow retry on next call
          },
        ),
      );
    } catch (e) {
      debugPrint('AdService._loadNavInterstitial error: $e');
      if (!(_interstitialLoadCompleter?.isCompleted ?? true)) {
        _interstitialLoadCompleter!.complete();
      }
      _interstitialLoadCompleter = null;
    }
  }

  /// Shows nav interstitial if ready. No-op for premium users.
  Future<void> showNavInterstitialIfReady() async {
    if (isPremiumUser) return;
    if (_navInterstitial == null) return;
    try {
      await _navInterstitial!.show();
    } catch (e) {
      debugPrint('AdService.showNavInterstitialIfReady error: $e');
      _navInterstitial?.dispose();
      _navInterstitial = null;
    }
  }

  /// Shows the interstitial on the splash -> onboarding transition (first launch).
  /// Waits up to [timeoutSeconds] for the ad to finish loading and resolves only
  /// after the ad is dismissed, so the caller navigates afterwards.
  /// No-op for premium users.
  Future<void> showSplashInterstitialIfReady({int timeoutSeconds = 5}) async {
    if (isPremiumUser || !interstitialEnabled) return;

    // Wait for the ongoing load to resolve (with a timeout so we never block navigation)
    final loadFuture = _interstitialLoadCompleter?.future;
    if (loadFuture != null && !(_interstitialLoadCompleter!.isCompleted)) {
      await loadFuture.timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          debugPrint('AdService: splash interstitial load timed out');
        },
      );
    }

    if (_navInterstitial == null) {
      _loadNavInterstitial(); // Retry in case the initial load failed
      return;
    }

    final showCompleter = Completer<void>();
    _navInterstitial!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _navInterstitial = null;
        _loadNavInterstitial(); // Preload for the nav tab-switch interstitial
        if (!showCompleter.isCompleted) showCompleter.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: splash interstitial failed to show: $error');
        ad.dispose();
        _navInterstitial = null;
        _loadNavInterstitial();
        if (!showCompleter.isCompleted) showCompleter.complete();
      },
    );

    try {
      _suppressNextAppOpen = true;
      await _navInterstitial!.show();
      await showCompleter.future;
    } catch (e) {
      _suppressNextAppOpen = false;
      debugPrint('AdService.showSplashInterstitialIfReady error: $e');
      _navInterstitial?.dispose();
      _navInterstitial = null;
      _loadNavInterstitial();
    }
  }

  // ---------------------------------------------------------------------------
  // Rewarded Ad
  // ---------------------------------------------------------------------------

  void _loadRewardedAd() {
    if (!rewardedEnabled) return;
    try {
      RewardedAd.load(
        adUnitId: AdConstants.rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            debugPrint('AdService: rewarded ad loaded');
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdService: rewarded ad failed to load: $error');
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      debugPrint('AdService._loadRewardedAd error: $e');
    }
  }

  /// Shows a rewarded ad if loaded. Calls [onRewarded] after the ad is dismissed
  /// and the user earned the reward. No-op for premium users (reward granted immediately).
  Future<void> showRewardedAdIfReady(
      {required Future<void> Function() onRewarded}) async {
    if (isPremiumUser) {
      await onRewarded();
      return;
    }

    if (_rewardedAd == null) {
      _showAdUnavailableSnackbar();
      _loadRewardedAd(); // Kick off a fresh load
      return;
    }

    final showCompleter = Completer<void>();
    bool rewarded = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        if (!showCompleter.isCompleted) showCompleter.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: rewarded ad failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        _loadRewardedAd();
        if (!showCompleter.isCompleted) showCompleter.complete();
      },
    );

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          rewarded = true;
        },
      );
      await showCompleter.future;
      if (rewarded) await onRewarded();
    } catch (e) {
      debugPrint('AdService.showRewardedAdIfReady error: $e');
      _rewardedAd?.dispose();
      _rewardedAd = null;
      _loadRewardedAd();
    }
  }

  void _showAdUnavailableSnackbar() {
    try {
      Get.snackbar(
        'Ad Not Available',
        'Please try again in a moment.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (_) {
      // Context may not be available; silently skip
    }
  }

  // ---------------------------------------------------------------------------
  // App Open Ad
  // ---------------------------------------------------------------------------

  void _loadAppOpenAd() {
    if (_appOpenAdLoadCompleter != null) return; // Already loading
    _appOpenAdLoadCompleter = Completer<void>();

    try {
      AppOpenAd.load(
        adUnitId: AdConstants.appOpenAdUnitId,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            _appOpenAd = ad;
            debugPrint('AdService: app open ad loaded');
            if (!(_appOpenAdLoadCompleter?.isCompleted ?? true)) {
              _appOpenAdLoadCompleter!.complete();
            }
            _appOpenAdLoadCompleter =
                null; // Allow a fresh load to be triggered if needed
          },
          onAdFailedToLoad: (error) {
            debugPrint('AdService: app open ad failed to load: $error');
            _appOpenAd = null;
            if (!(_appOpenAdLoadCompleter?.isCompleted ?? true)) {
              _appOpenAdLoadCompleter!.complete();
            }
            _appOpenAdLoadCompleter = null; // Allow retry on next call
          },
        ),
      );
    } catch (e) {
      debugPrint('AdService._loadAppOpenAd error: $e');
      if (!(_appOpenAdLoadCompleter?.isCompleted ?? true)) {
        _appOpenAdLoadCompleter!.complete();
      }
      _appOpenAdLoadCompleter = null;
    }
  }

  Future<bool> _isAppOpenAdAllowedByCooldown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastShown = prefs.getInt(_lastAppOpenAdKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      return (now - lastShown) >= _appOpenCooldownMs;
    } catch (e) {
      return true; // Allow if prefs unavailable
    }
  }

  Future<void> _recordAppOpenAdShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          _lastAppOpenAdKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('AdService._recordAppOpenAdShown error: $e');
    }
  }

  /// Shows App Open Ad if available and within the 4-hour frequency cap.
  /// Waits up to [timeoutSeconds] for the ad to finish loading.
  /// No-op for premium users.
  Future<void> showAppOpenAdIfReady({int timeoutSeconds = 3}) async {
    if (_suppressNextAppOpen) {
      _suppressNextAppOpen = false;
      return;
    }
    if (isPremiumUser) return;
    if (!await _isAppOpenAdAllowedByCooldown()) return;

    // Wait for the ongoing load to resolve (with a timeout so we never block navigation)
    final loadFuture = _appOpenAdLoadCompleter?.future;
    if (loadFuture != null && !(_appOpenAdLoadCompleter!.isCompleted)) {
      await loadFuture.timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          debugPrint('AdService: app open ad load timed out');
        },
      );
    }

    if (_appOpenAd == null) {
      _loadAppOpenAd(); // Retry in case the initial load failed
      return;
    }

    final showCompleter = Completer<void>();
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _appOpenAdLoadCompleter = null;
        _loadAppOpenAd(); // Preload for next resume
        _recordAppOpenAdShown();
        if (!showCompleter.isCompleted) showCompleter.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('AdService: app open ad failed to show: $error');
        ad.dispose();
        _appOpenAd = null;
        _appOpenAdLoadCompleter = null;
        _loadAppOpenAd();
        if (!showCompleter.isCompleted) showCompleter.complete();
      },
    );

    try {
      await _appOpenAd!.show();
      await showCompleter.future;
    } catch (e) {
      debugPrint('AdService.showAppOpenAdIfReady error: $e');
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _appOpenAdLoadCompleter = null;
      _loadAppOpenAd();
    }
  }
}
