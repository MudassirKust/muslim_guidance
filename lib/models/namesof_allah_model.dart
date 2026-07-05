class NameOfAllah {
  final int number;
  final String name;
  final String transliteration;
  final Map<String, String> meaning;

  NameOfAllah({
    required this.number,
    required this.name,
    required this.transliteration,
    required this.meaning,
  });

  factory NameOfAllah.fromJson(Map<String, dynamic> json) {
    return NameOfAllah(
      number: json['number'],
      name: json['name'],
      transliteration: json['transliteration'],
      meaning: Map<String, String>.from(json['meaning']),
    );
  }
}
