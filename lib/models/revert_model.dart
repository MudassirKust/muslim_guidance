// models/revert_model.dart

class RevertSection {
  final Map<String, String> sectionTitle;
  final Map<String, String> content;

  RevertSection({
    required this.sectionTitle,
    required this.content,
  });

  factory RevertSection.fromJson(Map<String, dynamic> json) {
    return RevertSection(
      sectionTitle: Map<String, String>.from(json['section_title'] ?? {}),
      content: Map<String, String>.from(json['content'] ?? {}),
    );
  }
}

class RevertModel {
  final Map<String, String> title;
  final List<RevertSection> sections;

  RevertModel({
    required this.title,
    required this.sections,
  });

  factory RevertModel.fromJson(Map<String, dynamic> json) {
    return RevertModel(
      title: Map<String, String>.from(json['title'] ?? {}),
      sections: (json['sections'] as List<dynamic>?)
              ?.map((e) => RevertSection.fromJson(e))
              .toList() ??
          [],
    );
  }
}
