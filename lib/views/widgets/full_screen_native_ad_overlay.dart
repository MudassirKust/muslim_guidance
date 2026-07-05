import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../controllers/ad_controller.dart';
import '../../services/ad_constants.dart';
import '../constants/appcolors.dart';

class FullScreenNativeAdOverlay extends StatefulWidget {
  const FullScreenNativeAdOverlay({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, __, ___) => const FullScreenNativeAdOverlay(),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  State<FullScreenNativeAdOverlay> createState() =>
      _FullScreenNativeAdOverlayState();
}

class _FullScreenNativeAdOverlayState extends State<FullScreenNativeAdOverlay> {
  NativeAd? _nativeAd;
  bool _adLoaded = false;
  bool _canDismiss = false;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _loadAd();
    _dismissTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _canDismiss = true);
    });
  }

  void _loadAd() {
    final adController = Get.find<AdController>();
    if (!adController.nativeEnabled.value) return;

    final ad = NativeAd(
      adUnitId: AdConstants.nativeAdUnitId,
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
        onAdLoaded: (_) {
          if (mounted) setState(() => _adLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('FullScreenNativeAd: failed to load: $error');
          ad.dispose();
        },
      ),
    );

    ad.load();
    _nativeAd = ad;
  }

  void _dismiss() {
    if (!_canDismiss) return;
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Swipe left to dismiss after 3 seconds
        if (_canDismiss && (details.primaryVelocity ?? 0) < -200) {
          _dismiss();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _adLoaded && _nativeAd != null
                      ? SizedBox(
                          height: 320,
                          child: AdWidget(ad: _nativeAd!),
                        )
                      : const SizedBox(
                          height: 320,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
              AnimatedOpacity(
                opacity: _canDismiss ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white38),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
