import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'splash_banner_ad_controller.dart';

class SplashBannerAdWidget extends StatelessWidget {
  const SplashBannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashBannerAdController());

    return Obx(() {
      if (!controller.isAdReady.value || controller.bannerAd == null) {
        return const SizedBox.shrink();
      }

      return SizedBox(
        width: controller.bannerAd!.size.width.toDouble(),
        height: controller.bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: controller.bannerAd!),
      );
    });
  }
}
