import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../controllers/ad_controller.dart';
import '../../services/ad_constants.dart';

class NativeAdSecondWidget extends StatefulWidget {
  final double? height;
  final TemplateType templateType;

  const NativeAdSecondWidget({
    super.key,
    this.height,
    this.templateType = TemplateType.small,
  });

  @override
  State<NativeAdSecondWidget> createState() => _NativeAdSecondWidgetState();
}

class _NativeAdSecondWidgetState extends State<NativeAdSecondWidget> {
  NativeAd? _nativeAd;
  bool _adLoaded = false;

  // Google's recommended minimum heights: small 90-200, medium 320-400.
  double get _height =>
      widget.height ?? (widget.templateType == TemplateType.medium ? 320 : 110);

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adController = Get.find<AdController>();
    if (!adController.nativeEnabled.value) return;

    final ad = NativeAd(
      adUnitId: kDebugMode
          ? "ca-app-pub-3940256099942544/2247696110"
          : AdConstants.nativeAdUnitId,
      request: const AdRequest(),
      factoryId: "medium_280",
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
