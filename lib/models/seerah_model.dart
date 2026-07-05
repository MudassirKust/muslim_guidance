class SeerahSection {
  final Map<String, String> sectionTitle;
  final Map<String, String> content;

  SeerahSection({
    required this.sectionTitle,
    required this.content,
  });

  factory SeerahSection.fromJson(Map<String, dynamic> json) {
    return SeerahSection(
      sectionTitle: (json['section_title'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString())) ??
          {},
      content: (json['content'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString())) ??
          {},
    );
  }
}
