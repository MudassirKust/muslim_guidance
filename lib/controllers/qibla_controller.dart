import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';

import '../views/constants/appcolors.dart';
import 'prayer_controller.dart';

class QiblaController extends GetxController {
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxDouble qiblaDirection = 0.0.obs;
  final RxDouble heading = 0.0.obs;
  final RxString locationName = "Loading...".obs;
  final RxString compassDirection = "Calculating...".obs;
  final RxString locationError = ''.obs;
  final RxBool hasCompass = false.obs;
  final RxBool isLoading = true.obs;
  final RxString qiblaAngleText = "0.0°".obs;
  final RxString qiblaDirectionLabel = "Calculating...".obs;
  final RxBool isVibrationOn = true.obs;
  StreamSubscription<CompassEvent>? _compassSubscription;
  final RxString loadingMessage = "Initializing...".obs;
  //final PrayerController prayerController = Get.find<PrayerController>();
  @override
  void onReady() async {
    super.onReady();
    debugPrint("QiblaController onReady called");

    isLoading.value = true;
    loadingMessage.value = "Getting location...";

    final PrayerController prayerController = Get.find<PrayerController>();
    latitude.value = prayerController.latitude.value;
    longitude.value = prayerController.longitude.value;

    _updateLocationName(latitude.value, longitude.value);

    // Wait for API to complete before moving on
    loadingMessage.value = "Fetching Qibla direction...";
    await _fetchQiblaDirection();

    // Now init compass
    loadingMessage.value = "Initializing compass...";
    _initCompass();

    // Done after compass init
    loadingMessage.value = "Done!";
    isLoading.value = false;
  }

  double get qiblaRotationAngle {
    return ((heading.value - qiblaDirection.value + 360) % 360);
  }

  // Future<void> _initLocationService() async {
  //   isLoading.value = true;
  //
  //   try {
  //     latitude.value = prayerController.latitude.value;
  //     longitude.value = prayerController.longitude.value;
  //
  //     _updateLocationName(latitude.value, longitude.value);
  //     await _fetchQiblaDirection();
  //   } catch (e) {
  //     locationError.value = 'Error getting location: ${e.toString()}';
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
  bool get isAlignedWithQibla {
    double diff = (qiblaRotationAngle - 0).abs();
    if (diff > 180) diff = 360 - diff;
    return diff <= 5;
  }

  bool _hasVibrated = false;

  Future<void> _checkAlignmentAndVibrate() async {
    try {
      if (!Platform.isAndroid && !Platform.isIOS) return;

      if (isAlignedWithQibla && !_hasVibrated && isVibrationOn.value) {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator) {
          Vibration.vibrate(duration: 100);
          _hasVibrated = true;
        }
      } else if (!isAlignedWithQibla) {
        _hasVibrated = false;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );
      debugPrint("Error checking vibration: $e");
    }
  }

  void toggleVibration() {
    isVibrationOn.value = !isVibrationOn.value;
  }

  Future<void> _fetchQiblaDirection() async {
    isLoading.value = true;
    loadingMessage.value = "Fetching Qibla direction from API...";
    try {
      final response = await http.get(Uri.parse(
          'https://api.aladhan.com/v1/qibla/${latitude.value}/${longitude.value}'));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final direction = json['data']['direction']?.toDouble() ?? 0.0;
        qiblaDirection.value = direction;
        qiblaAngleText.value = "${direction.toStringAsFixed(2)}°";
        qiblaDirectionLabel.value = _getDirectionLabel(direction);
        loadingMessage.value = "Qibla direction received";
        isLoading.value = false;
      } else {
        Get.snackbar(
          "Error",
          'Failed to fetch Qibla direction from API',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.bgColorThemed(Get.context!),
          colorText: AppColors.blackTextThemed(Get.context!),
          duration: const Duration(seconds: 3),
        );
        loadingMessage.value = "Failed to fetch Qibla direction";
        locationError.value = 'Failed to fetch Qibla direction from API';
        isLoading.value = false;
      }
      loadingMessage.value = "Qibla direction received";
      isLoading.value = false;
    } catch (e) {
      Get.snackbar(
        "API Error",
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );
      loadingMessage.value = "Error fetching Qibla direction";
      locationError.value = 'API Error: ${e.toString()}';
      //isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  void _initCompass() {
    loadingMessage.value = "Checking compass sensor...";
    if (FlutterCompass.events == null) {
      hasCompass.value = false;
      Get.snackbar(
        "Error",
        'Compass not available on this device',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );
      loadingMessage.value = "Compass not available";
      locationError.value = 'Compass not available on this device';
      return;
    }

    hasCompass.value = true;
    loadingMessage.value = "Compass initialized";
    _compassSubscription = FlutterCompass.events!.listen((event) {
      if (event.heading != null && event.heading!.isFinite) {
        heading.value = event.heading!;
        compassDirection.value = _getDirectionLabel(heading.value);
        _checkAlignmentAndVibrate();
      }
    });
  }

  void _updateLocationName(double lat, double lng) {
    locationName.value =
        "Lat: ${lat.toStringAsFixed(4)}, Lon: ${lng.toStringAsFixed(4)}";
  }

  String _getDirectionLabel(double angle) {
    const directions = [
      "North",
      "North-East",
      "East",
      "South-East",
      "South",
      "South-West",
      "West",
      "North-West"
    ];
    if (!angle.isFinite) return directions[0];
    int index = ((angle + 22.5) % 360 ~/ 45) % 8;
    return directions[index];
  }

  // void _updateCompassDirection() {
  //   double direction = heading.value % 360; // normalize

  //   if (direction >= 337.5 || direction < 22.5) {
  //     compassDirection.value = "North";
  //   } else if (direction >= 22.5 && direction < 67.5) {
  //     compassDirection.value = "North-East";
  //   } else if (direction >= 67.5 && direction < 112.5) {
  //     compassDirection.value = "East";
  //   } else if (direction >= 112.5 && direction < 157.5) {
  //     compassDirection.value = "South-East";
  //   } else if (direction >= 157.5 && direction < 202.5) {
  //     compassDirection.value = "South";
  //   } else if (direction >= 202.5 && direction < 247.5) {
  //     compassDirection.value = "South-West";
  //   } else if (direction >= 247.5 && direction < 292.5) {
  //     compassDirection.value = "West";
  //   } else if (direction >= 292.5 && direction < 337.5) {
  //     compassDirection.value = "North-West";
  //   }
  // }

  @override
  void onClose() {
    _compassSubscription?.cancel();
    _hasVibrated = false;
    //isVibrationOn.value = false;
    debugPrint("QiblaController onClose called");
    super.onClose();
  }
}
