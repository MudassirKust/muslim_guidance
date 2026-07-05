import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/hajj_model.dart';

class HajjController extends GetxController {
  var regularSections = <HajjSection>[].obs;
  var expandableSections = <HajjSection>[].obs;
  var expandedSections = <int>{}.obs;
  var isAllExpanded = false.obs;

  String getLanguageKey() {
    final lang = Get.locale?.languageCode ?? 'en';
    switch (lang) {
      case 'en':
        return 'en';
      case 'ar':
        return 'ar';
      case 'ur':
        return 'ur';
      case 'sv':
        return 'sv';
      case 'es':
        return 'es';
      case 'no':
        return 'no';
      case 'fr':
        return 'fr';
      case 'de':
        return 'de';
      case 'nl':
        return 'nl';
      case 'fi':
        return 'fi';
      case 'ps':
        return 'ps';
      case 'id':
        return 'id';
      case 'tr':
        return 'tr';
      case 'bn':
        return 'bn';
      case 'so':
        return 'so';
      default:
        return 'en';
    }
  }

  void toggleSection(int index) {
    if (expandedSections.contains(index)) {
      expandedSections.remove(index);
    } else {
      expandedSections.add(index);
    }
  }

  bool isSectionExpanded(int index) {
    return expandedSections.contains(index);
  }

  void toggleAllSections() {
    isAllExpanded.value = !isAllExpanded.value;
  }

  Future<void> loadHajjData() async {
    try {
      final response =
          await rootBundle.loadString('assets/data/hajj_complete.json');
      debugPrint("Debug: JSON loaded successfully from hajj_complete.json");

      final Map<String, dynamic> data = json.decode(response);
      debugPrint("Debug: JSON decoded successfully");

      if (data.containsKey('Hajj')) {
        final hajjData = data['Hajj'] as Map<String, dynamic>;
        debugPrint("Debug: Hajj data keys: ${hajjData.keys}");

        // Check if we have the new structure
        if (hajjData.containsKey('regular_sections') ||
            hajjData.containsKey('expandable_sections')) {
          debugPrint(
              "Debug: Found new structure with regular_sections/expandable_sections keys");
          final hajjDataObj = HajjData.fromJson(data);
          regularSections.value = hajjDataObj.regularSections;
          expandableSections.value = hajjDataObj.expandableSections;
          debugPrint(
              "✅ Hajj loaded with ${regularSections.length} regular sections and ${expandableSections.length} expandable sections");
          return;
        }

        // Check if we have the old structure (fallback)
        if (hajjData.containsKey('sections')) {
          debugPrint(
              "Debug: Found old structure with 'sections' key - converting");
          final sections = hajjData['sections'] as List;
          regularSections.value =
              sections.map((e) => HajjSection.fromJson(e)).toList();
          expandableSections.value = [];
          debugPrint(
              "✅ Hajj loaded with ${regularSections.length} sections (converted from old structure)");
          return;
        }

        debugPrint("Debug: Unknown structure found");
      }

      debugPrint("Debug: No Hajj data found in JSON");
    } catch (e) {
      debugPrint("❌ Error loading Hajj data: $e");
    }
  }
}
