import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:islamlearning/services/permission_coordinator.dart';
import 'package:islamlearning/views/constants/appcolors.dart';

class PrayerTimesService {
  Future<Map<String, String>> getPrayerTimes(
      Position position, int asrMethod) async {
    try {
      final latitude = position.latitude;
      final longitude = position.longitude;
      final date = DateTime.now();

      final url = Uri.parse(
        'http://api.aladhan.com/v1/timings/${date.millisecondsSinceEpoch ~/ 1000}?latitude=$latitude&longitude=$longitude&method=2&asr=$asrMethod&school=$asrMethod',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          final timings = data['data']['timings'];
          return Map<String, String>.from(timings);
        } else {
          throw Exception(
              'Failed to load prayer times: ${data['code']} - ${data['status']}');
        }
      } else {
        throw Exception('Failed to load prayer times: ${response.statusCode}');
      }
    } on SocketException {
      Get.snackbar(
        "No Internet Connection",
        "Please check your internet connection and try again",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );
      rethrow;
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to load prayer times. Please try again later.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );
      return {};
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Error is handled in the controller with proper dialog
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await PermissionCoordinator()
          .run(() => Geolocator.requestPermission());
      if (permission == LocationPermission.denied) {
        // Error is handled in the controller with proper dialog
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Error is handled in the controller with proper dialog
      return Future.error(
          'Location permissions are permanently denied, please enable them in app settings.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      // desiredAccuracy: LocationAccuracy.high
    );
  }

  Future<Map<String, String>> getPrayerTimesBasedOnLocation(
      int asrMethod) async {
    try {
      final position = await _determinePosition();
      return await getPrayerTimes(position, asrMethod);
    } on SocketException {
      // SocketException is already handled in getPrayerTimes, just return empty
      return {};
    } catch (e) {
      // Error is handled in the controller with proper dialogs
      // Don't show redundant snackbar here
      return {};
    }
  }
}
