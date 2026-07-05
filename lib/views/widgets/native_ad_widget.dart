import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../controllers/ad_controller.dart';
import '../../services/ad_constants.dart';
import '../constants/appcolors.dart';

class NativeAdWidget extends StatefulWidget {
  final double? height;
  final TemplateType templateType;

  const NativeAdWidget({
    super.key,
    this.height,
    this.templateType = TemplateType.small,
  });

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _adLoaded = false;

  // Google's recommended minimum heights: small 90-200, medium 320-400.
  double get _height =>
      widget.height ?? (widget.templateType == TemplateType.medium ? 320 : 120);

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adController = Get.find<AdController>();
    if (!adController.nativeEnabled.value) return;

    final ad = NativeAd(
      adUnitId: AdConstants.nativeAdUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: widget.templateType,
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
          debugPrint('Native ad failed to load: $error');
          ad.dispose();
        },
      ),
    );

    ad.load();
    setState(() => _nativeAd = ad);
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdController>();
    return Obx(() {
      if (!adController.nativeEnabled.value ||
          !_adLoaded ||
          _nativeAd == null) {
        return const SizedBox.shrink();
      }
      return SizedBox(
        height: _height,
        child: AdWidget(ad: _nativeAd!),
      );
    });
  }
}
