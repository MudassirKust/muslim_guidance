import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/hadith_model.dart';

class HadithController extends GetxController {
  final hadithData = Rx<HadithCollection?>(null);
  final isLoading = false.obs;

  final currentSource = ''.obs;

  String get currentLang => Get.locale?.languageCode ?? 'en';

  String localized(Map<String, String> data) {
    return data[currentLang] ?? data['en'] ?? '';
  }

  Future<void> loadHadithIfNeeded(String bookId) async {
    debugPrint("🔎 Requested book ID: $bookId");
    if (_isTopicBook(bookId) && currentSource.value != 'topics') {
      await _loadHadithTopicData();
    } else if (!_isTopicBook(bookId) && currentSource.value != 'complete') {
      await _loadHadithData();
    }
  }

  bool _isTopicBook(String bookId) {
    return bookId.startsWith('hadith_on_') || bookId == 'hadith_of_gabriel';
  }

  Future<void> _loadHadithTopicData() async {
    try {
      isLoading.value = true;
      final jsonString = await rootBundle
          .loadString('assets/data/hadith_topics_complete.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      hadithData.value = HadithCollection.fromJson(jsonData);
      currentSource.value = 'topics';
      debugPrint("📘 Loaded hadith_topics_complete.json");
      debugPrint(
          "📚 Available book IDs: ${hadithData.value?.books.keys.toList()}");
    } catch (e) {
      debugPrint("❌ Error loading hadith topic data: $e");
      Get.snackbar('error'.tr, 'failed_to_load_hadith'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadHadithData() async {
    try {
      isLoading.value = true;
      final jsonString =
          await rootBundle.loadString('assets/data/hadith_complete.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      hadithData.value = HadithCollection.fromJson(jsonData);
      currentSource.value = 'complete';
      debugPrint("📘 Loaded hadith_complete.json");
      debugPrint(
          "📚 Available book IDs: ${hadithData.value?.books.keys.toList()}");
    } catch (e) {
      debugPrint("❌ Error loading hadith data: $e");
      Get.snackbar('error'.tr, 'failed_to_load_hadith'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  HadithBook? getBookById(String bookId) {
    return hadithData.value?.books[bookId];
  }
}
