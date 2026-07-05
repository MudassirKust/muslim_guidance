// controllers/faq_controller.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/faq_model.dart';

class FaqController extends GetxController {
  final RxList<FaqCategory> faqData = <FaqCategory>[].obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxList<RxBool> expansionStates = <RxBool>[].obs;
  final RxBool isLoading = true.obs;
  String get currentLang => Get.locale?.languageCode ?? 'en';
  String localized(Map<String, String> data) {
    return data[currentLang] ?? data['en'] ?? '';
  }
  @override
  void onInit() {
    super.onInit();
    loadFaqData();
  }

  Future<void> loadFaqData() async {
    try {
      isLoading.value = true;
      final jsonString = await rootBundle.loadString('assets/data/questions_answers_complete.json');
      final jsonData = json.decode(jsonString);

      final categories = (jsonData['categories'] as List)
          .map((category) => FaqCategory.fromJson(category))
          .toList();

      faqData.assignAll(categories);

      if (faqData.isNotEmpty) {
        resetExpansionStates();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load FAQ data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void resetExpansionStates() {
    expansionStates.assignAll(
      faqData[selectedCategoryIndex.value].items.map((_) => false.obs),
    );
  }

  void changeCategory(int index) {
    selectedCategoryIndex.value = index;
    resetExpansionStates();
  }

  void toggleExpansion(int index, bool isExpanded) {
    expansionStates[index].value = isExpanded;
  }
}