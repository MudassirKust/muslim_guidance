class RuqiyahAudio {
  final int id;
  final String titleArabic;
  final String titleEnglish;
  final String descriptionKey;
  final String audioUrl;
  int replayCount;

  RuqiyahAudio({
    required this.id,
    required this.titleArabic,
    required this.titleEnglish,
    required this.descriptionKey,
    required this.audioUrl,
    this.replayCount = 1,
  });

  RuqiyahAudio copyWith({
    int? id,
    String? titleArabic,
    String? titleEnglish,
    String? descriptionKey,
    String? audioUrl,
    int? replayCount,
  }) {
    return RuqiyahAudio(
      id: id ?? this.id,
      titleArabic: titleArabic ?? this.titleArabic,
      titleEnglish: titleEnglish ?? this.titleEnglish,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      audioUrl: audioUrl ?? this.audioUrl,
      replayCount: replayCount ?? this.replayCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleArabic': titleArabic,
      'titleEnglish': titleEnglish,
      'descriptionKey': descriptionKey,
      'audioUrl': audioUrl,
      'replayCount': replayCount,
    };
  }

  factory RuqiyahAudio.fromJson(Map<String, dynamic> json) {
    return RuqiyahAudio(
      id: json['id'] as int,
      titleArabic: json['titleArabic'] as String,
      titleEnglish: json['titleEnglish'] as String,
      descriptionKey: json['descriptionKey'] as String,
      audioUrl: json['audioUrl'] as String,
      replayCount: json['replayCount'] as int? ?? 1,
    );
  }

  @override
  String toString() {
    return 'RuqiyahAudio(id: $id, titleEnglish: $titleEnglish, titleArabic: $titleArabic, replayCount: $replayCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RuqiyahAudio && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
