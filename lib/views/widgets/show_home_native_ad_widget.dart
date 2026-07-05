import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:islamlearning/controllers/auth_controller.dart';
import 'package:islamlearning/views/premium_screen.dart';
import 'package:islamlearning/views/signin_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:islamlearning/controllers/ad_controller.dart';
import 'package:islamlearning/services/ad_service.dart';
import 'package:islamlearning/views/widgets/home_native_ad_controller.dart';

class ShowHomeNativeAdWidget extends StatefulWidget {
  const ShowHomeNativeAdWidget({super.key});

  @override
  State<ShowHomeNativeAdWidget> createState() => _ShowHomeNativeAdWidgetState();
}

class _ShowHomeNativeAdWidgetState extends State<ShowHomeNativeAdWidget> {
  final AdService service = AdService.instance;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<HomeNativeAdController>()) {}
  }

  @override
  Widget build(BuildContext context) {
    final adController = Get.find<AdController>();
    final authController = Get.find<AuthController>();

    return Obx(() {
      final controller = Get.find<HomeNativeAdController>();

      if (service.isPremiumUser || !adController.nativeEnabled.value) {
        return const SizedBox.shrink();
      }

      // Hide entire widget if nothing to show
      if (!controller.isAdReady.value && !controller.isAdLoading.value) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          // clipBehavior: Clip.none,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Obx(() {
              if (!controller.isAdReady.value && !controller.isAdShow.value) {
                return const SizedBox.shrink();
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      debugPrint("button clicked");
                      if (authController.isSignedIn) {
                        Get.to(() => const PremiumScreen());
                      } else {
                        Get.to(() => const SignInScreen());
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 22,
                          width: 22,
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),

            /// AD AREA — full height, no top padding
            SizedBox(
              height: 280,
              child: _buildAdOrShimmer(controller),
            ),

            /// CLOSE BUTTON — floats on top right, outside ad bounds
          ],
        ),
      );
    });
  }

  Widget _buildAdOrShimmer(HomeNativeAdController controller) {
    if (controller.isAdReady.value && controller.nativeAd1 != null) {
      return AdWidget(ad: controller.nativeAd1!);
    }

    if (controller.isAdLoading.value) {
      return _buildShimmer();
    }

    return const SizedBox.shrink();
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: 280,
        // margin: const EdgeInsets.s ymmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          // borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
