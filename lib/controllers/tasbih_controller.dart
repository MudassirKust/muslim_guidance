import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/tasbih_model.dart';
import '../views/constants/appcolors.dart';

class TasbihController extends GetxController {
  var dhikrList = <TasbihDhikr>[].obs;
  var selectedDhikrIndex = 0.obs;
  var count = 0.obs;
  var targetCount = 33.obs;
  var isVibrating = false.obs;
  var totalCount = 0.obs; // Track total counts across all sessions
  var sessionCount = 0.obs; // Track counts for current session
  var isCompleted = false.obs; // Track if target is completed
  var completionTime = Rxn<DateTime>(); // Track when target was completed

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

  TasbihDhikr get selectedDhikr {
    if (dhikrList.isEmpty) {
      return TasbihDhikr(
        id: 0,
        arabic: '',
        transliteration: {},
        translation: {},
        virtue: {},
      );
    }
    return dhikrList[selectedDhikrIndex.value];
  }

  void selectDhikr(int index) {
    if (index >= 0 && index < dhikrList.length) {
      selectedDhikrIndex.value = index;
      resetCount();
    }
  }

  void incrementCount() {
    count.value++;
    sessionCount.value++;
    totalCount.value++;

    // Check if target is reached
    if (count.value >= targetCount.value && !isCompleted.value) {
      isCompleted.value = true;
      completionTime.value = DateTime.now();

      // Enhanced vibration feedback
      isVibrating.value = true;
      HapticFeedback.heavyImpact();

      // Reset vibration after animation
      Future.delayed(const Duration(milliseconds: 300), () {
        isVibrating.value = false;
      });

      // Show completion message
      Get.snackbar(
        'Target Reached! 🎉',
        'You have completed ${targetCount.value} ${selectedDhikr.transliteration[getLanguageKey()] ?? selectedDhikr.transliteration['en'] ?? ''}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.appbarText.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );
    }
  }

  void decrementCount() {
    if (count.value > 0) {
      count.value--;
      sessionCount.value--;
      totalCount.value--;

      // Reset completion status if count goes below target
      if (count.value < targetCount.value && isCompleted.value) {
        isCompleted.value = false;
        completionTime.value = null;
      }
    }
  }

  void resetCount() {
    count.value = 0;
    isCompleted.value = false;
    completionTime.value = null;
  }

  void resetSession() {
    sessionCount.value = 0;
    resetCount();
  }

  void setTargetCount(int target) {
    targetCount.value = target;
    resetCount();
  }

  void nextDhikr() {
    if (dhikrList.isNotEmpty) {
      selectedDhikrIndex.value =
          (selectedDhikrIndex.value + 1) % dhikrList.length;
      resetCount();
    }
  }

  void previousDhikr() {
    if (dhikrList.isNotEmpty) {
      selectedDhikrIndex.value = selectedDhikrIndex.value == 0
          ? dhikrList.length - 1
          : selectedDhikrIndex.value - 1;
      resetCount();
    }
  }

  // Get progress percentage
  double get progressPercentage {
    if (targetCount.value <= 0) return 0.0;
    return (count.value / targetCount.value).clamp(0.0, 1.0);
  }

  // Get remaining count
  int get remainingCount {
    return (targetCount.value - count.value).clamp(0, targetCount.value);
  }

  // Check if target is completed
  bool get isTargetCompleted {
    return count.value >= targetCount.value;
  }

  // Get completion message
  String get completionMessage {
    final dhikrName = selectedDhikr.transliteration[getLanguageKey()] ??
        selectedDhikr.transliteration['en'] ??
        '';
    return 'Completed $targetCount $dhikrName!';
  }

  // Get statistics
  Map<String, dynamic> get statistics {
    return {
      'totalCount': totalCount.value,
      'sessionCount': sessionCount.value,
      'currentCount': count.value,
      'targetCount': targetCount.value,
      'progress': progressPercentage,
      'remaining': remainingCount,
      'isCompleted': isCompleted.value,
      'completionTime': completionTime.value,
    };
  }

  Future<void> loadTasbihData() async {
    try {
      final response =
          await rootBundle.loadString('assets/data/TasbihCounter.json');
      debugPrint("Debug: JSON loaded successfully from TasbihCounter.json");

      final Map<String, dynamic> data = json.decode(response);
      debugPrint("Debug: JSON decoded successfully");

      final tasbihData = TasbihData.fromJson(data);
      dhikrList.value = tasbihData.dhikrList;

      debugPrint("✅ Tasbih loaded with ${dhikrList.length} dhikr items");
    } catch (e) {
      debugPrint("❌ Error loading Tasbih data: $e");
    }
  }
}
