// Model: dua_model.dart
class DailyDua {
  final int id;
  final Map<String, String> situation;
  final String arabic;
  final String transliteration;
  final Map<String, String> meaning;
  final String source;

  DailyDua({
    required this.id,
    required this.situation,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.source,
  });

  factory DailyDua.fromJson(Map<String, dynamic> json) {
    return DailyDua(
      id: json['id'],
      situation: Map<String, String>.from(json['situation'] ?? {}),
      arabic: json['arabic_dua'] ?? '',
      transliteration: json['transliteration'] ?? '',
      meaning: Map<String, String>.from(json['meaning'] ?? {}),
      source: json['source'] ?? '',
    );
  }
}
