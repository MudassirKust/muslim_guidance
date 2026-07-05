import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/fiqh_model.dart';

class FiqhController extends GetxController {
  var fiqhModel = Rxn<FiqhModel>();

  String getLangKey() {
    final lang = Get.locale?.languageCode ?? 'en';
    switch (lang) {
      case 'ar':
        return 'Arabic';
      case 'ur':
        return 'Urdu';
      default:
        return 'English';
    }
  }

  Future<void> loadFiqhData() async {
    try {
      final response = await rootBundle.loadString('assets/data/fiqh.json');
      final jsonData = json.decode(response);
      fiqhModel.value = FiqhModel.fromJson(jsonData);
      debugPrint('✅ Fiqh Data Loaded');
    } catch (e) {
      debugPrint('❌ Error loading fiqh.json: $e');
    }
  }
}
