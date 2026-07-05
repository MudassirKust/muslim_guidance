import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/dua_model.dart';

class DuaController extends GetxController {
  final isLoading = true.obs;
  final categoryDuas = <DuaModel>[].obs;
  String get currentLang => Get.locale?.languageCode ?? 'en';
  Future<void> loadDuas(String categoryKey) async {
    try {
      isLoading.value = true;
      final String jsonString =
          await rootBundle.loadString('assets/data/dua_complete.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> categoryList = jsonData[categoryKey];
      final List<DuaModel> loadedDuas =
          categoryList.map((e) => DuaModel.fromJson(e)).toList();

      categoryDuas.value = loadedDuas;
    } catch (e) {
      debugPrint('❌ Error loading duas: $e');
      categoryDuas.clear();
    } finally {
      isLoading.value = false;
    }
  }

  String localized(Map<String, String> data) {
    return data[currentLang] ?? data['en'] ?? '';
  }
}
