import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/ramadan_model.dart';

class RamadanController extends GetxController {
  var regularSections = <RamadanSection>[].obs;
  var expandableSections = <RamadanSection>[].obs;
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

  Future<void> loadRamadanData() async {
    try {
      final response =
          await rootBundle.loadString('assets/data/ramadan_complete.json');
      debugPrint("Debug: JSON loaded successfully from ramadan_complete.json");

      final Map<String, dynamic> data = json.decode(response);
      debugPrint("Debug: JSON decoded successfully");

      if (data.containsKey('Ramadan')) {
        final ramadanData = data['Ramadan'] as Map<String, dynamic>;
        debugPrint("Debug: Ramadan data keys: ${ramadanData.keys}");

        // Check if we have the new structure
        if (ramadanData.containsKey('regular_sections') ||
            ramadanData.containsKey('expandable_sections')) {
          debugPrint(
              "Debug: Found new structure with regular_sections/expandable_sections keys");
          final ramadanDataObj = RamadanData.fromJson(data);
          regularSections.value = ramadanDataObj.regularSections;
          expandableSections.value = ramadanDataObj.expandableSections;
          debugPrint(
              "✅ Ramadan loaded with ${regularSections.length} regular sections and ${expandableSections.length} expandable sections");
          return;
        }

        // Check if we have the old structure (fallback)
        if (ramadanData.containsKey('sections')) {
          debugPrint(
              "Debug: Found old structure with 'sections' key - converting");
          final sections = ramadanData['sections'] as List;
          regularSections.value =
              sections.map((e) => RamadanSection.fromJson(e)).toList();
          expandableSections.value = [];
          debugPrint(
              "✅ Ramadan loaded with ${regularSections.length} sections (converted from old structure)");
          return;
        }

        debugPrint("Debug: Unknown structure found");
      }

      debugPrint("Debug: No Ramadan data found in JSON");
    } catch (e) {
      debugPrint("❌ Error loading Ramadan data: $e");
    }
  }
}
