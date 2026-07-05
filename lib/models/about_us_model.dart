class AboutUsData {
  final Map<String, String> translations;

  AboutUsData({
    required this.translations,
  });

  factory AboutUsData.fromJson(Map<String, dynamic> json) {
    final translationsData = json['translations'] as Map<String, dynamic>? ?? {};
    
    final translations = <String, String>{};
    translationsData.forEach((key, value) {
      if (value is Map<String, dynamic> && value.containsKey('text')) {
        translations[key] = value['text'] as String? ?? '';
      }
    });

    return AboutUsData(
      translations: translations,
    );
  }

  String getText(String languageCode) {
    // Map language codes to the JSON keys
    final languageMap = {
      'en': 'eu', // The JSON uses 'eu' for English
      'ar': 'ar',
      'ur': 'ur',
      'fr': 'fr',
      'nl': 'nl',
      'es': 'es',
      'sv': 'sv',
      'no': 'no',
      'fi': 'fi',
      'ps': 'ps',
      'id': 'id',
      'tr': 'tr',
      'de': 'de',
      'bn': 'bn',
      'so': 'so',
    };

    final jsonKey = languageMap[languageCode] ?? 'eu';
    return translations[jsonKey] ?? translations['eu'] ?? '';
  }
}








