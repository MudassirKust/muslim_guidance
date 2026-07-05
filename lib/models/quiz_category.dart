enum QuizCategory { normal, seerah, islamicHistory, nobleQuran }

extension QuizCategoryExtension on QuizCategory {
  String get assetPath {
    switch (this) {
      case QuizCategory.normal:
        return 'assets/data/quiz_normal.json';
      case QuizCategory.seerah:
        return 'assets/data/quiz_seerah.json';
      case QuizCategory.islamicHistory:
        return 'assets/data/quiz_islamic_history.json';
      case QuizCategory.nobleQuran:
        return 'assets/data/quiz_noble_quran.json';
    }
  }

  String get progressKey => 'quiz_progress_$name';

  // Total levels per category based on question pool size
  // Normal: 99 q → 8 levels (shuffled)
  // Noble Quran: 101 q → 8 levels (shuffled)
  // Seerah: 75 q → 5 levels × 15 = 75 (exact)
  // Islamic History: 24 q → 2 levels × 12 = 24 (exact)
  int get totalLevels {
    switch (this) {
      case QuizCategory.normal:
        return 8;
      case QuizCategory.nobleQuran:
        return 8;
      case QuizCategory.seerah:
        return 5;
      case QuizCategory.islamicHistory:
        return 2;
    }
  }

  int get questionsPerLevel {
    switch (this) {
      case QuizCategory.islamicHistory:
        return 12; // 24 questions / 2 levels = 12 each
      default:
        return 15;
    }
  }
}