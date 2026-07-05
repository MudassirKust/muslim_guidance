import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamlearning/controllers/ad_controller.dart';
import 'package:islamlearning/services/ad_service.dart';
import 'package:islamlearning/views/widgets/location_permission_ads_controller.dart';

class ShowLocationPermissionAdWidget extends StatefulWidget {
  const ShowLocationPermissionAdWidget({super.key});

  @override
  State<ShowLocationPermissionAdWidget> createState() =>
      _ShowLocationPermissionAdWidgetState();
}

class _ShowLocationPermissionAdWidgetState
    extends State<ShowLocationPermissionAdWidget> {
  final AdService service = AdService.instance;

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdController>();

    return Obx(() {
      final controller = Get.find<LocationPermissionAdsController>();

      return service.isPremiumUser || !adController.nativeEnabled.value
          ? SizedBox()
          : Column(
              children: [
                if (controller.isAdLoading.value &&
                    controller.nativeAd1 == null) ...[
                  SizedBox(
                    height: 350,
                  )
                ] else if (!controller.isAdLoading.value &&
                    controller.nativeAd1 != null) ...[
                  SizedBox(
                    height: 350,
                    child: AdWidget(ad: controller.nativeAd1!),
                  ),
                ]
              ],
            );
    });
  }
}
