// dhikr_controller.dart
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/dhikr_model.dart';

class DhikrController extends GetxController {
  var isLoading = true.obs;
  var dhikrCollection = Rxn<DhikrCollection>();
  String get currentLang => Get.locale?.languageCode ?? 'en';
  String localized(Map<String, String> data) {
    return data[currentLang] ?? data['en'] ?? '';
  }
  @override
  void onInit() {
    loadDhikrData();
    super.onInit();
  }

  Future<void> loadDhikrData() async {
    try {
      isLoading(true);
      final jsonString = await rootBundle.loadString('assets/data/dhikr_complete.json');
      final jsonData = await json.decode(jsonString);
      dhikrCollection.value = DhikrCollection.fromJson(jsonData);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load dhikr data: $e');
    } finally {
      isLoading(false);
    }
  }

  DhikrCategory? getCategory(int index) {
    if (dhikrCollection.value == null || index >= dhikrCollection.value!.categories.length) {
      return null;
    }
    return dhikrCollection.value!.categories[index];
  }
}