import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/daily_dua.dart';

class DailyDuaController extends GetxController {
  var dailyDuas = <DailyDua>[].obs;
  @override
  void onInit() {
    super.onInit();
    loadDailyDuas();
  }

  String getLanguageKey() {
    final locale = Get.locale?.languageCode ?? 'en';
    return locale;
  }

  Future<void> loadDailyDuas() async {
    try {
      final response =
          await rootBundle.loadString('assets/data/daily_routine.json');
      final Map<String, dynamic> data = json.decode(response);
      final List<dynamic> duaList = data['daily_duas'] ?? [];
      dailyDuas.value = duaList.map((e) => DailyDua.fromJson(e)).toList();
      debugPrint('✅ Loaded ${dailyDuas.length} daily duas');
    } catch (e) {
      debugPrint('❌ Error loading daily_routine.json: $e');
    }
  }
}
