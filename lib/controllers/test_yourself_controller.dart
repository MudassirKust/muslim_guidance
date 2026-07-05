import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/quiz_question.dart';
import '../models/quiz_progress.dart';
import '../models/quiz_category.dart';
import '../services/ad_service.dart';
import '../views/constants/appcolors.dart';
import 'subscription_controller.dart';

class QuizController extends GetxController {
  // Constants
  static const int freeLevels = 3;
  // Per-category helpers (delegate to QuizCategory extension)
  int get totalLevels => selectedCategory.value.totalLevels;
  int get questionsPerLevel => selectedCategory.value.questionsPerLevel;
  static const double passPercentage = 80.0;
  static const int passMinCorrect = 12;

  // Observables
  final questions = <QuizQuestion>[].obs;
  final currentQuestionIndex = 0.obs;
  final selectedOptionIndex = (-1).obs;
  final showCorrectAnswer = false.obs;
  final score = 0.obs;
  final isQuizCompleted = false.obs;
  final currentLevel = 1.obs;
  final levelPassed = false.obs;
  final levelFailed = false.obs;
  final completedLevel =
      0.obs; // Store which level was just completed (for display)
  final completedScore =
      0.obs; // Store the score for the completed level (for display)
  final allLevelsCompleted = false.obs;
  final premiumRequired = false.obs;
  final isLoading = false.obs;
  final error = ''.obs;

  // Category selector state
  final showCategorySelector = false.obs;
  final selectedCategory = QuizCategory.normal.obs;
  final hintRevealed = false.obs;
  final isRequestingHint = false.obs;

  QuizProgress? _progress;

  String get currentLang => Get.locale?.languageCode ?? 'en';

  String localized(Map<String, String> data) {
    return data[currentLang] ?? data['en'] ?? '';
  }

  int get correctAnswerIndex =>
      questions[currentQuestionIndex.value].answerIndex;

  @override
  void onInit() {
    super.onInit();
    const bool premiumOverride = false;
    final subscriptionController = Get.find<SubscriptionController>();
    if (premiumOverride || subscriptionController.isPremium) {
      showCategorySelector.value = true;
    } else {
      initializeQuiz(QuizCategory.normal);
    }
  }

  void startCategory(QuizCategory category) {
    selectedCategory.value = category;
    showCategorySelector.value = false;
    initializeQuiz(category);
  }

  Future<void> initializeQuiz(QuizCategory category) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Load saved progress for this category
      _progress = await QuizProgress.load(key: category.progressKey);
      if (_progress != null) {
        currentLevel.value = _progress!.currentLevel;
      }

      // Load questions for current level
      await loadQuizData(category);
    } catch (e) {
      error.value = 'Failed to initialize quiz: $e';
      Get.snackbar(
        'Error',
        'Failed to initialize quiz. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadQuizData(QuizCategory category) async {
    try {
      isLoading.value = true;
      error.value = '';

      final String data = await rootBundle.loadString(category.assetPath);
      final List<dynamic> jsonList = jsonDecode(data);
      final loadedQuestions =
          jsonList.map((json) => QuizQuestion.fromJson(json)).toList();

      // Shuffle to randomize questions (different seed per level for variety)
      loadedQuestions.shuffle();

      // Take questionsPerLevel questions for the level
      questions.value = loadedQuestions.sublist(
        0,
        loadedQuestions.length < questionsPerLevel
            ? loadedQuestions.length
            : questionsPerLevel,
      );

      // Reset quiz state for new level
      currentQuestionIndex.value = 0;
      selectedOptionIndex.value = -1;
      showCorrectAnswer.value = false;
      score.value = 0;
      isQuizCompleted.value = false;
      levelPassed.value = false;
      levelFailed.value = false;
      hintRevealed.value = false;
      isRequestingHint.value = false;
    } catch (e) {
      error.value = 'Failed to load quiz data: $e';
      Get.snackbar(
        'Error',
        'Failed to load quiz questions. Please try again.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.bgColorThemed(Get.context!),
        colorText: AppColors.blackTextThemed(Get.context!),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectOption(int index) {
    selectedOptionIndex.value = index;
    showCorrectAnswer.value = true;

    if (index == correctAnswerIndex) {
      score.value++;
    }
  }

  Future<void> requestHintViaAd() async {
    if (isRequestingHint.value) return;
    isRequestingHint.value = true;
    try {
      await AdService.instance.showRewardedAdIfReady(
        onRewarded: () async {
          hintRevealed.value = true;
          selectOption(correctAnswerIndex);
        },
      );
    } finally {
      isRequestingHint.value = false;
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      selectedOptionIndex.value = -1;
      showCorrectAnswer.value = false;
      hintRevealed.value = false;
    } else {
      completeLevel();
    }
  }

  bool checkLevelPass() {
    final totalQuestions = questions.length;
    if (totalQuestions == 0) return false;

    final percentage = (score.value / totalQuestions) * 100;
    return percentage >= passPercentage || score.value >= passMinCorrect;
  }

  Future<void> completeLevel() async {
    isQuizCompleted.value = true;

    // Store the level and score that was just completed (before we change/reset anything)
    completedLevel.value = currentLevel.value;
    completedScore.value = score.value;

    // Save score for current level
    _progress ??= QuizProgress();
    _progress!.levelScores[completedLevel.value] = completedScore.value;

    final passed = checkLevelPass();
    _progress!.levelPassed[completedLevel.value] = passed;

    final progressKey = selectedCategory.value.progressKey;

    if (passed) {
      // Check if all levels completed (we just completed the last level)
      if (completedLevel.value >= totalLevels) {
        levelPassed.value = true;
        allLevelsCompleted.value = true;
        await _progress!.save(key: progressKey);
        return;
      }

      // Check if free user trying to go beyond free levels (only for normal category)
      final subscriptionController = Get.find<SubscriptionController>();
      if (selectedCategory.value == QuizCategory.normal &&
          completedLevel.value >= freeLevels &&
          !subscriptionController.isPremium) {
        levelPassed.value = true;
        premiumRequired.value = true;
        await _progress!.save(key: progressKey);
        return;
      }

      levelPassed.value = true;
      await _progress!.save(key: progressKey);

      // currentLevel increment is handled in continueToNextLevel()
    } else {
      // Failed - reset to Level 1
      levelFailed.value = true;
      await resetToLevelOne();
    }
  }

  // Reset all progress to Level 1
  Future<void> resetToLevelOne() async {
    final progressKey = selectedCategory.value.progressKey;
    _progress ??= QuizProgress();
    _progress!.reset();
    currentLevel.value = 1;
    await _progress!.save(key: progressKey);

    // Reset quiz state
    score.value = 0;
    currentQuestionIndex.value = 0;
    selectedOptionIndex.value = -1;
    showCorrectAnswer.value = false;
    allLevelsCompleted.value = false;
    premiumRequired.value = false;
  }

  // Continue to next level (called from UI after showing completion message)
  Future<void> continueToNextLevel() async {
    levelPassed.value = false;
    premiumRequired.value = false;
    currentLevel.value++;
    _progress!.currentLevel = currentLevel.value;
    await _progress!.save(key: selectedCategory.value.progressKey);
    await loadQuizData(selectedCategory.value);
  }

  // Restart from Level 1 (called from UI)
  Future<void> restartQuiz() async {
    await resetToLevelOne();
    await loadQuizData(selectedCategory.value);
    isQuizCompleted.value = false;
    levelFailed.value = false;
  }

  // Retry loading quiz data
  void retry() {
    error.value = '';
    loadQuizData(selectedCategory.value);
  }

  // Go back to category selector (premium users)
  void backToCategories() {
    questions.value = [];
    isQuizCompleted.value = false;
    levelPassed.value = false;
    levelFailed.value = false;
    allLevelsCompleted.value = false;
    premiumRequired.value = false;
    error.value = '';
    showCategorySelector.value = true;
  }

  @override
  void onClose() {
    // Cleanup if needed in the future
    super.onClose();
  }
}
