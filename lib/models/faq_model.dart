import '../views/constants/appimages.dart';

class FaqItem {
  final Map<String, String> questionTranslations;
  final Map<String, String> answerTranslations;
  final String? source;

  FaqItem({
    required this.questionTranslations,
    required this.answerTranslations,
    this.source,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      questionTranslations: Map<String, String>.from(json['question']),
      answerTranslations: Map<String, String>.from(json['answer']),
      source: json['source'],
    );
  }
}

class FaqCategory {
  final String categoryName;
  final String iconPath;
  final List<FaqItem> items;

  FaqCategory({
    required this.categoryName,
    required this.iconPath,
    required this.items,
  });

  factory FaqCategory.fromJson(Map<String, dynamic> json) {
    return FaqCategory(
      categoryName: json['categoryName'],
      iconPath: _getIconForCategory(json['categoryName']),
      items: (json['items'] as List)
          .map((item) => FaqItem.fromJson(item))
          .toList(),
    );
  }

  /// Returns the translation key for Easy Localization
  String get translationKey => _getTranslationKey(categoryName);

  static String _getTranslationKey(String name) {
    switch (name) {
      case 'Prayer Q&A':
        return 'prayer_qa';
      case 'Marriage Q&A':
        return 'marriage_qa';
      case 'Hajj Q&A':
        return 'hajj_qa';
      case 'Purification (Taharah) Q&A':
        return 'purification_qa';
      case 'Signs of the Hour Q&A':
        return 'signs_hour_qa';
      case 'Akhlaq (Manners & Character) Q&A':
        return 'akhlaq_qa';
      case 'General Islamic Q&A':
        return 'general_islamic_qa';
      default:
        return name; // fallback to original if not mapped
    }
  }

  static String _getIconForCategory(String categoryName) {
    switch (categoryName) {
      case 'Prayer Q&A':
        return AppImages.prayers;
      case 'Marriage Q&A':
        return AppImages.women;
      case 'Hajj Q&A':
        return AppImages.hajj;
      case 'Purification (Taharah) Q&A':
        return AppImages.pure;
      case 'Signs of the Hour Q&A':
        return AppImages.endsigns;
      case 'Akhlaq (Manners & Character) Q&A':
        return AppImages.akhlaq;
      case 'General Islamic Q&A':
      default:
        return AppImages.general;
    }
  }
}
