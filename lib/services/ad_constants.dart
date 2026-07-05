import 'dart:io';

class AdConstants {
  static const bool _useTestIds = false;

  // Google's cross-platform test IDs
  static const String _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testNative = 'ca-app-pub-3940256099942544/2247696110';
  static const String _testRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testAppOpen = 'ca-app-pub-3940256099942544/9257395922';

  // Android production
  static const String _prodAndroidOnboardNativeAd =
      'ca-app-pub-8144392055317892/8647445079';
  static const String _prodAndroidBanner =
      'ca-app-pub-8144392055317892/7703681144';
  static const String _prodAndroidInterstitial =
      'ca-app-pub-8144392055317892/2694897045';
  static const String _prodAndroidNative =
      'ca-app-pub-8144392055317892/3565791865';
  static const String _prodAndroidRewarded =
      'ca-app-pub-8144392055317892/8944472940';
  static const String _prodAndroidAppOpen =
      'ca-app-pub-8144392055317892/6953463375';

  // iOS production
  static const String _prodIosBanner = 'ca-app-pub-8144392055317892/7631198728';
  static const String _prodIosInterstitial =
      'ca-app-pub-8144392055317892/1257362063';
  static const String _prodIosNative = 'ca-app-pub-8144392055317892/9451242930';
  static const String _prodIosRewarded =
      'ca-app-pub-8144392055317892/1502950246';
  static const String _prodIosAppOpen =
      'ca-app-pub-8144392055317892/5504259061';

  static String get bannerAdUnitId {
    if (_useTestIds) return _testBanner;
    return Platform.isIOS ? _prodIosBanner : _prodAndroidBanner;
  }

  static String get nativeLanguageOnboardAdUnitId {
    if (_useTestIds) return _testNative;
    return Platform.isIOS
        ? _prodAndroidOnboardNativeAd
        : _prodAndroidOnboardNativeAd;
  }

  static String get interstitialAdUnitId {
    if (_useTestIds) return _testInterstitial;
    return Platform.isIOS ? _prodIosInterstitial : _prodAndroidInterstitial;
  }

  static String get nativeAdUnitId {
    if (_useTestIds) return _testNative;
    return Platform.isIOS ? _prodIosNative : _prodAndroidNative;
  }

  static String get rewardedAdUnitId {
    if (_useTestIds) return _testRewarded;
    return Platform.isIOS ? _prodIosRewarded : _prodAndroidRewarded;
  }

  static String get appOpenAdUnitId {
    if (_useTestIds) return _testAppOpen;
    return Platform.isIOS ? _prodIosAppOpen : _prodAndroidAppOpen;
  }
}
