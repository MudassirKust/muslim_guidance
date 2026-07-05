import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/umrah_model.dart';

class UmrahController extends GetxController {
  var regularSections = <UmrahSection>[].obs;
  var expandableSections = <UmrahSection>[].obs;
  var expandedSections = <int>{}.obs;
  var isAllExpanded = false.obs;

  String getLanguageKey() {
    final lang = Get.locale?.languageCode ?? 'en';
    // Use language codes directly as they match the JSON structure
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
        return 'en'; // Default to English
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

  Future<void> loadUmrahData() async {
    try {
      final response =
          await rootBundle.loadString('assets/data/umrah_complete.json');
      debugPrint("Debug: JSON loaded successfully from umrah_complete.json");

      final Map<String, dynamic> data = json.decode(response);
      debugPrint("Debug: JSON decoded successfully");

      if (data.containsKey('Umrah')) {
        final umrahData = data['Umrah'] as Map<String, dynamic>;
        debugPrint("Debug: Umrah data keys: ${umrahData.keys}");

        // Check if we have the new structure
        if (umrahData.containsKey('regular_sections') ||
            umrahData.containsKey('expandable_sections')) {
          debugPrint(
              "Debug: Found new structure with regular_sections/expandable_sections keys");
          final umrahDataObj = UmrahData.fromJson(data);
          regularSections.value = umrahDataObj.regularSections;
          expandableSections.value = umrahDataObj.expandableSections;
          debugPrint(
              "✅ Umrah loaded with ${regularSections.length} regular sections and ${expandableSections.length} expandable sections");
          return;
        }

        // Check if we have the old structure (fallback)
        if (umrahData.containsKey('sections')) {
          debugPrint(
              "Debug: Found old structure with 'sections' key - converting");
          final sections = umrahData['sections'] as List;
          regularSections.value =
              sections.map((e) => UmrahSection.fromJson(e)).toList();
          expandableSections.value = [];
          debugPrint(
              "✅ Umrah loaded with ${regularSections.length} sections (converted from old structure)");
          return;
        }

        debugPrint("Debug: Unknown structure found");
      }

      debugPrint("Debug: No Umrah data found in JSON");
    } catch (e) {
      debugPrint("❌ Error loading Umrah data: $e");
    }
  }
}
