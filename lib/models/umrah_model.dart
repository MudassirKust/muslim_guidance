class UmrahSection {
  final Map<String, String> sectionTitle;
  final Map<String, String> content;

  UmrahSection({
    required this.sectionTitle,
    required this.content,
  });

  factory UmrahSection.fromJson(Map<String, dynamic> json) {
    return UmrahSection(
      sectionTitle: (json['section_title'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString())) ??
          {},
      content: (json['content'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString())) ??
          {},
    );
  }
}

class UmrahData {
  final List<UmrahSection> regularSections;
  final List<UmrahSection> expandableSections;

  UmrahData({
    required this.regularSections,
    required this.expandableSections,
  });

  factory UmrahData.fromJson(Map<String, dynamic> json) {
    final umrahData = json['Umrah'] ?? {};
    
    final regularSections = (umrahData['regular_sections'] as List?)
        ?.map((e) => UmrahSection.fromJson(e))
        .toList() ?? [];
        
    final expandableSections = (umrahData['expandable_sections'] as List?)
        ?.map((e) => UmrahSection.fromJson(e))
        .toList() ?? [];

    return UmrahData(
      regularSections: regularSections,
      expandableSections: expandableSections,
    );
  }
}
