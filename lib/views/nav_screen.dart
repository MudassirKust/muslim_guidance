import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:islamlearning/controllers/subscription_controller.dart';
import 'package:islamlearning/services/local_manager.dart';
import 'package:islamlearning/views/audio_screen.dart';
import 'package:islamlearning/views/constants/appcolors.dart';
import 'package:islamlearning/views/constants/appimages.dart';
import 'package:islamlearning/views/explore_screen.dart';
import 'package:islamlearning/views/prayer_screen.dart';
import 'package:islamlearning/views/qibla_screen.dart';
import 'package:islamlearning/views/settings_screen.dart';
import 'package:islamlearning/views/widgets/back_press_interstital_ad_controller.dart';
import 'package:islamlearning/views/widgets/discount_paywall_dialog.dart';
import 'package:islamlearning/views/widgets/home_native_ad_controller.dart';
import 'package:islamlearning/views/widgets/location_permission_bottom_sheet.dart';
import '../controllers/nav_controller.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:islamlearning/services/update_service.dart';
import 'package:islamlearning/views/widgets/themed_upgrade_alert.dart';

class NavScreen extends StatefulWidget {
  final int initialIndex;

  const NavScreen({super.key, this.initialIndex = 0});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  final RxString selectedLanguage = 'English'.obs;
  final BackPressInterstitialController _globalInterstitialAdsController =
      Get.isRegistered<BackPressInterstitialController>()
          ? Get.find<BackPressInterstitialController>()
          : Get.put(BackPressInterstitialController(), permanent: true);
  @override
  void initState() {
    super.initState();
    Get.put(HomeNativeAdController(), permanent: true);
    _globalInterstitialAdsController.loadAd();
    Get.put(NavController()).selectedNavIndex.value = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shown = await LocaleManager.isPaywallShown();
      final subCtrl = Get.find<SubscriptionController>();
      if (!shown && !subCtrl.isPremium) {
        await LocaleManager.savePaywallShown();
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black54,
            builder: (_) => const DiscountPaywallDialog(),
          );
        }
      }
    });
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return const ExploreScreen();
      case 1:
        return PrayerScreen();
      case 2:
        return QiblaScreen();
      case 3:
        return AudioScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const ExploreScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final NavController navController = Get.find();

    return ThemedUpgradeAlert(
      upgrader: UpdateService.instance.upgrader,
      barrierDismissible: true,
      child: Obx(() {
        return Scaffold(
          backgroundColor: AppColors.bgColorThemed(context),
          body: Column(
            children: [
              Expanded(
                child: _getScreenForIndex(navController.selectedNavIndex.value),
              ),
            ],
          ),
          bottomNavigationBar: Obx(() {
            return SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.cyanGreen,
                      AppColors.greenTeal,
                      AppColors.darkMintGreen,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(5, (index) {
                    final isSelected =
                        navController.selectedNavIndex.value == index;
                    final svgIcons = [
                      AppImages.explore,
                      AppImages.prayer,
                      AppImages.qibla,
                      AppImages.quran,
                      AppImages.setting,
                    ];
                    final labels = [
                      'explore',
                      'prayer',
                      'qibla',
                      'quran',
                      'setting'
                    ];

                    return Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (index == 1) {
                            final permission =
                                await Geolocator.checkPermission();
                            if (permission == LocationPermission.denied) {
                              if (context.mounted) {
                                showLocationPermissionBottomSheet(
                                  context,
                                  onPermissionGranted: () =>
                                      navController.changeTab(1),
                                );
                              }
                              return;
                            }
                          }
                          navController.changeTab(index);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.buttonColor
                                      : Colors.transparent,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5)),
                                ),
                                child: SvgPicture.asset(
                                  svgIcons[index],
                                  height: 24,
                                  colorFilter: ColorFilter.mode(
                                    isSelected
                                        ? AppColors.buttonText
                                        : AppColors.navbarText,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                easy.tr(labels[index]),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}
