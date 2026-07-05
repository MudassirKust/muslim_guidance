import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:islamlearning/models/namesof_allah_model.dart';

class NamesController extends GetxController {
  var names = <NameOfAllah>[].obs;
  var isLoading = true.obs;
  String get currentLang => Get.locale?.languageCode ?? 'en';
  String localized(Map<String, String> data) {
    return data[currentLang] ?? data['en'] ?? '';
  }

  @override
  void onInit() {
    loadNames();
    super.onInit();
  }

  Future<void> loadNames() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/data/names_of_allah.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      names.value = jsonData.map((e) => NameOfAllah.fromJson(e)).toList();
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
