class Surah {
  final String surahName;
  final String englishName;
  final String englishNameTranslation;
  final int surahNumber;
  final int totalVerses;
  final String revelationType;
  bool isFavorite;
  String? audioUrl;
  Duration? duration;
  Duration? nextTwoDuration;
  List<Ayah> ayahs;
  final bool isCached;
  Surah({
    required this.surahName,
    required this.englishName,
    required this.englishNameTranslation,
    required this.surahNumber,
    required this.totalVerses,
    required this.revelationType,
    this.isFavorite = false,
    this.audioUrl,
    this.duration,
    this.nextTwoDuration,
    required this.ayahs,
    this.isCached = false,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    final ayahs = (json['ayahs'] as List<dynamic>?)
            ?.map((ayah) => Ayah.fromJson(ayah))
            .toList() ??
        [];

    return Surah(
      surahName: json['name'] ?? 'N/A',
      englishName: json['englishName'] as String? ?? 'N/A',
      englishNameTranslation: json['englishNameTranslation'] as String? ?? '',
      surahNumber: json['number'] ?? 0,
      totalVerses: json['numberOfAyahs'] ?? 0,
      revelationType: json['revelationType'] ?? 'Unknown',
      isFavorite: json['isFavorite'] ?? false,
      ayahs: ayahs,
      audioUrl: json['audio_url'] as String?,
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'] as int)
          : null,
      nextTwoDuration: json['next_two_duration'] != null
          ? Duration(seconds: json['next_two_duration'] as int)
          : null,
    );
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }

  Surah copyWith({
    String? surahName,
    String? englishName,
    String? englishNameTranslation,
    int? surahNumber,
    int? totalVerses,
    String? revelationType,
    bool? isFavorite,
    String? audioUrl,
    Duration? duration,
    Duration? nextTwoDuration,
    List<Ayah>? ayahs,
    bool? isCached,
  }) {
    return Surah(
      surahName: surahName ?? this.surahName,
      englishName: englishName ?? this.englishName,
      englishNameTranslation:
          englishNameTranslation ?? this.englishNameTranslation,
      surahNumber: surahNumber ?? this.surahNumber,
      totalVerses: totalVerses ?? this.totalVerses,
      revelationType: revelationType ?? this.revelationType,
      isFavorite: isFavorite ?? this.isFavorite,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      nextTwoDuration: nextTwoDuration ?? this.nextTwoDuration,
      ayahs: ayahs ?? this.ayahs,
      isCached: isCached ?? this.isCached,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': surahName,
      'englishName': englishName,
      'englishNameTranslation': englishNameTranslation,
      'number': surahNumber,
      'numberOfAyahs': totalVerses,
      'revelationType': revelationType,
      'isFavorite': isFavorite,
      'audio_url': audioUrl,
      'duration': duration?.inSeconds,
      'next_two_duration': nextTwoDuration?.inSeconds,
      'ayahs': ayahs.map((ayah) => ayah.toJson()).toList(),
      'isCached': isCached,
    };
  }
}

class Ayah {
  final String arabic;
  final String audioUrl;
  final int numberInSurah;
  final String? translation;

  Ayah({
    required this.arabic,
    required this.audioUrl,
    required this.numberInSurah,
    this.translation,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      arabic: json['text']?.toString() ?? '',
      audioUrl: json['audio']?.toString() ?? '',
      numberInSurah: json['numberInSurah'] ?? 0,
      translation: json['translation']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': arabic,
      'audio': audioUrl,
      'numberInSurah': numberInSurah,
      'translation': translation,
    };
  }
}
