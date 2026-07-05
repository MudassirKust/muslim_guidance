class HajjSection {
  final Map<String, String> sectionTitle;
  final Map<String, String> content;

  HajjSection({
    required this.sectionTitle,
    required this.content,
  });

  factory HajjSection.fromJson(Map<String, dynamic> json) {
    return HajjSection(
      sectionTitle: (json['section_title'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString())) ??
          {},
      content: (json['content'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString())) ??
          {},
    );
  }
}

class HajjData {
  final List<HajjSection> regularSections;
  final List<HajjSection> expandableSections;

  HajjData({
    required this.regularSections,
    required this.expandableSections,
  });

  factory HajjData.fromJson(Map<String, dynamic> json) {
    final hajjData = json['Hajj'] ?? {};
    
    final regularSections = (hajjData['regular_sections'] as List?)
        ?.map((e) => HajjSection.fromJson(e))
        .toList() ?? [];
        
    final expandableSections = (hajjData['expandable_sections'] as List?)
        ?.map((e) => HajjSection.fromJson(e))
        .toList() ?? [];

    return HajjData(
      regularSections: regularSections,
      expandableSections: expandableSections,
    );
  }
}

