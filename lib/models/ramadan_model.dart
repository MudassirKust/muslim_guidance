class RamadanSection {
  final Map<String, String> sectionTitle;
  final Map<String, String> content;

  RamadanSection({
    required this.sectionTitle,
    required this.content,
  });

  factory RamadanSection.fromJson(Map<String, dynamic> json) {
    return RamadanSection(
      sectionTitle: (json['section_title'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString())) ??
          {},
      content: (json['content'] as Map?)?.map(
              (key, value) => MapEntry(key.toString(), value.toString())) ??
          {},
    );
  }
}

class RamadanData {
  final List<RamadanSection> regularSections;
  final List<RamadanSection> expandableSections;

  RamadanData({
    required this.regularSections,
    required this.expandableSections,
  });

  factory RamadanData.fromJson(Map<String, dynamic> json) {
    final ramadanData = json['Ramadan'] ?? {};
    
    final regularSections = (ramadanData['regular_sections'] as List?)
        ?.map((e) => RamadanSection.fromJson(e))
        .toList() ?? [];
        
    final expandableSections = (ramadanData['expandable_sections'] as List?)
        ?.map((e) => RamadanSection.fromJson(e))
        .toList() ?? [];

    return RamadanData(
      regularSections: regularSections,
      expandableSections: expandableSections,
    );
  }
}

