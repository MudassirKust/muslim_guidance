// controllers/revert_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/revert_model.dart';

class RevertController extends GetxController {
  var revertData = Rxn<RevertModel>();

  String get currentLang => Get.locale?.languageCode ?? 'en';

  Future<void> loadRevertData() async {
    try {
      final response = await rootBundle.loadString('assets/data/revert.json');
      final Map<String, dynamic> data = json.decode(response);
      revertData.value = RevertModel.fromJson(data);
      debugPrint("✅ Revert data loaded");
    } catch (e) {
      debugPrint("❌ Failed to load revert.json: $e");
    }
  }

  String localized(Map<String, String> data) {
    return data[currentLang] ?? data['en'] ?? '';
  }
}
