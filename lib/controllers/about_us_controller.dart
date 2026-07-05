import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../models/about_us_model.dart';

class AboutUsController extends GetxController {
  var aboutUsData = Rxn<AboutUsData>();
  var isLoading = true.obs;

  String getLanguageKey() {
    final lang = Get.locale?.languageCode ?? 'en';
    switch (lang) {
      case 'en':
        return 'en';
      case 'ar':
        return 'ar';
      case 'ur':
        return 'ur';
      case 'fr':
        return 'fr';
      case 'nl':
        return 'nl';
      case 'es':
        return 'es';
      case 'sv':
        return 'sv';
      case 'no':
        return 'no';
      case 'fi':
        return 'fi';
      case 'ps':
        return 'ps';
      case 'id':
        return 'id';
      case 'tr':
        return 'tr';
      case 'de':
        return 'de';
      case 'bn':
        return 'bn';
      case 'so':
        return 'so';
      default:
        return 'en';
    }
  }

  String getAboutUsText() {
    if (aboutUsData.value == null) return '';
    final lang = getLanguageKey();
    return aboutUsData.value!.getText(lang);
  }

  Future<void> loadAboutUsData() async {
    try {
      isLoading.value = true;
      final response = await rootBundle.loadString('assets/data/AboutUs.json');
      debugPrint("Debug: JSON loaded successfully from AboutUs.json");

      final Map<String, dynamic> data = json.decode(response);
      debugPrint("Debug: JSON decoded successfully");

      aboutUsData.value = AboutUsData.fromJson(data);

      debugPrint("✅ About Us loaded successfully");
    } catch (e) {
      debugPrint("❌ Error loading About Us data: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
