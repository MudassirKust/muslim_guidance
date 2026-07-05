class DhikrItem {
  final String? no;
  final String? arabicDhikr;
  final String? translation;
  final String? explanation;

  DhikrItem({
    this.no,
    this.arabicDhikr,
    this.translation,
    this.explanation,
  });

  factory DhikrItem.fromJson(Map<String, dynamic> json, String langKey) {
    String? extract(dynamic field) {
      if (field == null) return null;
      if (field is String) return field;
      if (field is Map<String, dynamic>) {
        return field[langKey] ?? field['English'] ?? field.values.first;
      }
      return field.toString();
    }

    return DhikrItem(
      no: extract(json['No.']),
      arabicDhikr: extract(json['Arabic Dhikr']),
      translation: extract(json['English Translation']),
      explanation: extract(json['Meaning / Explanation']),
    );
  }
}
