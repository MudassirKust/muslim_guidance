class DuaModel {
  final int id;
  final Map<String, String> situation;
  final String arabic;
  final String transliteration;
  final Map<String, String> meaning;
  final String source;

  DuaModel({
    required this.id,
    required this.situation,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
    required this.source,
  });

  factory DuaModel.fromJson(Map<String, dynamic> json) {
    return DuaModel(
      id: json['id'],
      situation: Map<String, String>.from(json['situation']),
      arabic: json['arabic_dua'],
      transliteration: json['transliteration'],
      meaning: Map<String, String>.from(json['meaning']),
      source: json['source'],
    );
  }
}

class DuaCategoryModel {
  final String title;
  final List<DuaModel> duas;

  DuaCategoryModel({
    required this.title,
    required this.duas,
  });
}
