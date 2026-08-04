import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Import your controllers here
import 'qibla_controller.dart';
import 'auth_controller.dart';
import 'package:islamlearning/services/ad_service.dart';
import 'package:islamlearning/services/local_manager.dart';
import 'package:islamlearning/views/premium_screen.dart';

class NavController extends GetxController {
  final selectedNavIndex = 0.obs;
  int _tabSwitchCount = 0;

  final RxString currentTime = ''.obs;
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  Timer? _timeTimer;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void onInit() {
    super.onInit();
    _startTimeUpdater();
    _getLocationStream();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationIfNeeded();
      _maybePresentPremiumScreen();
    });

    // AppReviewService.scheduleReviewIfNeeded(
    //   isOnHomeScreen: () => selectedNavIndex.value == 0,
    // );
  }

  Future<void> _maybePresentPremiumScreen() async {
    final authController = Get.find<AuthController>();
    if (authController.isPremium) return;

    final shouldShow = await LocaleManager.isThirdLaunch();
    if (!shouldShow) return;

    await Future.delayed(const Duration(seconds: 1));
    Get.to(() => const PremiumScreen());
  }

  void changeTab(int newIndex) {
    // Dispose current tab's controller before switching
    _disposeControllerForTab(selectedNavIndex.value);

    // Change tab
    selectedNavIndex.value = newIndex;

    _tabSwitchCount++;
    if (_tabSwitchCount >= AdService.instance.screenSwitchThreshold) {
      _tabSwitchCount = 0;
      AdService.instance.showNavInterstitialIfReady();
    }
  }

  void _disposeControllerForTab(int index) {
    switch (index) {
      // case 0:
      //   if (Get.isRegistered<PrayerController>()) {
      //     Get.delete<PrayerController>(force: true);
      //   }
      //   break;
      case 2:
        if (Get.isRegistered<QiblaController>()) {
          Get.delete<QiblaController>(force: true);
        }
        break;
      // case 3:
      //   if (Get.isRegistered<AudioController>()) {
      //     Get.delete<AudioController>(force: true);
      //   }
      //   break;
    }
  }

  void _startTimeUpdater() {
    // Use explicit 'en_US' locale to prevent crash on unsupported device
    // locales (e.g. om_ET - Oromo/Ethiopia) that intl doesn't bundle.
    currentTime.value =
        DateFormat('hh:mm:ss a', 'en_US').format(DateTime.now());
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      currentTime.value =
          DateFormat('hh:mm:ss a', 'en_US').format(DateTime.now());
    });
  }

  /// Start the location stream if permission is already granted.
  /// Does NOT request permission — the Prayer tab bottom sheet handles that
  /// so the user is never shown a bare system dialog on NavScreen load.
  Future<void> _requestLocationIfNeeded() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getLocationStream();
    }
  }

  void _getLocationStream() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(
        (Position position) {
          latitude.value = position.latitude;
          longitude.value = position.longitude;
        },
        onError: (e) =>
            debugPrint('Location stream error (e.g. GPS disabled): $e'),
      );
    } catch (e) {
      debugPrint('Location stream error (e.g. GPS disabled): $e');
    }
  }

  @override
  void onClose() {
    _timeTimer?.cancel();
    _positionSubscription?.cancel();
    super.onClose();
  }
}
