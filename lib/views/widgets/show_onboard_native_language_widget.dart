import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamlearning/services/ad_service.dart';
import 'package:islamlearning/views/widgets/language_ads_controller.dart';

class ShowOnboardNativeLanguageWidget extends StatefulWidget {
  const ShowOnboardNativeLanguageWidget({super.key});

  @override
  State<ShowOnboardNativeLanguageWidget> createState() =>
      _ShowOnboardNativeLanguageWidgetState();
}

class _ShowOnboardNativeLanguageWidgetState
    extends State<ShowOnboardNativeLanguageWidget> {
  final AdService service = AdService.instance;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<LanguageAdsController>();

      return service.isPremiumUser
          ? SizedBox()
          : Column(
              children: [
                // First Ad - Shown initially
                if (!controller.showSecondAdOnly.value &&
                    controller.isFirstAdLoaded.value &&
                    controller.nativeAd1 != null)
                  SizedBox(
                    height: 280,
                    child: AdWidget(ad: controller.nativeAd1!),
                  ),

                // Second Ad - Shown after language selection
                if (controller.showSecondAdOnly.value &&
                    controller.isSecondAdLoaded.value &&
                    controller.nativeAd2 != null)
                  SizedBox(
                    height: 280,
                    child: AdWidget(ad: controller.nativeAd2!),
                  ),
              ],
            );
    });
  }
}
