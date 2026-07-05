import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/seerah_model.dart';

class SeerahController extends GetxController {
  var sections = <SeerahSection>[].obs;
  var expandableSections = <SeerahSection>[].obs;
  var isAllExpanded = false.obs;

  String getLanguageKey() {
    return Get.locale?.languageCode ?? 'en'; // returns 'en', 'ar', 'ur', etc.
  }

  Future<void> loadSeerahData() async {
    try {
      final response = await rootBundle.loadString('assets/data/seerah.json');
      final Map<String, dynamic> data = json.decode(response);
      final sectionList = data['Seerah']?['sections'] ?? [];
      debugPrint(sectionList);
      debugPrint(sections.toString());

      // Split sections into main and expandable
      final allSections =
          (sectionList as List).map((e) => SeerahSection.fromJson(e)).toList();

      // Show first 3 sections initially, rest as expandable
      if (allSections.length > 3) {
        sections.value = allSections.take(3).toList();
        expandableSections.value = allSections.skip(3).toList();
      } else {
        sections.value = allSections;
        expandableSections.value = [];
      }

      debugPrint(
          "✅ Seerah loaded with ${sections.length} main sections and ${expandableSections.length} expandable sections");
    } catch (e) {
      debugPrint("❌ Error loading seerah.json: $e");
    }
  }

  void toggleAllSections() {
    isAllExpanded.value = !isAllExpanded.value;
  }
}
