// dhikr_model.dart
class Dhikr {
  final int id;
  final String arabic;
  final String transliteration;
  final Map<String, String> meaning;

  Dhikr({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
  });

  factory Dhikr.fromJson(Map<String, dynamic> json) {
    return Dhikr(
      id: json['id'],
      arabic: json['arabic_dhikr'],
      transliteration: json['transliteration'],
      meaning: Map<String, String>.from(json['meaning']),
    );
  }
}

class DhikrCategory {
  final String title;
  final List<Dhikr> dhikrs;
  final Map<String, String> localizedName;

  DhikrCategory({
    required this.title,
    required this.dhikrs,
    required this.localizedName,
  });

  factory DhikrCategory.fromJson(Map<String, dynamic> json) {
    return DhikrCategory(
      title: json['category_name']['en'] ?? 'Dhikr',
      localizedName: Map<String, String>.from(json['category_name']),
      dhikrs:
          (json['items'] as List).map((item) => Dhikr.fromJson(item)).toList(),
    );
  }
}

class DhikrCollection {
  final List<DhikrCategory> categories;

  DhikrCollection({required this.categories});

  factory DhikrCollection.fromJson(Map<String, dynamic> json) {
    final collection = json['dhikr_collection'] as Map<String, dynamic>;
    return DhikrCollection(
      categories: collection.values
          .map((category) => DhikrCategory.fromJson(category))
          .toList(),
    );
  }
}
