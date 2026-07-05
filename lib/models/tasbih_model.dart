class TasbihDhikr {
  final int id;
  final String arabic;
  final Map<String, String> transliteration;
  final Map<String, String> translation;
  final Map<String, String> virtue;

  TasbihDhikr({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.virtue,
  });

  factory TasbihDhikr.fromJson(Map<String, dynamic> json) {
    return TasbihDhikr(
      id: json['id'] ?? 0,
      arabic: json['arabic'] ?? '',
      transliteration: (json['transliteration'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          {},
      translation: (json['translation'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          {},
      virtue: (json['virtue'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ) ??
          {},
    );
  }
}

class TasbihData {
  final List<TasbihDhikr> dhikrList;

  TasbihData({
    required this.dhikrList,
  });

  factory TasbihData.fromJson(Map<String, dynamic> json) {
    final dhikrCollection = json['dhikr_collection'] ?? {};
    final dhikr = dhikrCollection['dhikr'] as List? ?? [];
    
    final dhikrList = dhikr.map((e) => TasbihDhikr.fromJson(e)).toList();

    return TasbihData(
      dhikrList: dhikrList,
    );
  }
}








