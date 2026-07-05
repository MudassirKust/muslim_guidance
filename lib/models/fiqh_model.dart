class FiqhModel {
  final Map<String, String> title;
  final Map<String, String> introduction;
  final FiqhFoundations foundations;
  final FiqhSources sources;
  final Map<String, String> modernRelevance;
  final FiqhSchools schools;
  final Map<String, String> conclusion;

  FiqhModel({
    required this.title,
    required this.introduction,
    required this.foundations,
    required this.sources,
    required this.modernRelevance,
    required this.schools,
    required this.conclusion,
  });

  factory FiqhModel.fromJson(Map<String, dynamic> json) {
    final fiqh = json['Fiqh'];
    return FiqhModel(
      title: Map<String, String>.from(fiqh['title']),
      introduction: Map<String, String>.from(fiqh['introduction']),
      foundations: FiqhFoundations.fromJson(fiqh['foundations']),
      sources: FiqhSources.fromJson(fiqh['sources']),
      modernRelevance: Map<String, String>.from(fiqh['modern_relevance']),
      schools: FiqhSchools.fromJson(fiqh['schools']),
      conclusion: Map<String, String>.from(fiqh['conclusion']),
    );
  }
}

class FiqhFoundations {
  final Map<String, String> title;
  final Map<String, String> description;
  final Map<String, String> ibadat;
  final Map<String, String> muamalat;

  FiqhFoundations({
    required this.title,
    required this.description,
    required this.ibadat,
    required this.muamalat,
  });

  factory FiqhFoundations.fromJson(Map<String, dynamic> json) {
    return FiqhFoundations(
      title: Map<String, String>.from(json['title']),
      description: Map<String, String>.from(json['description']),
      ibadat: Map<String, String>.from(json['domains']['ibadat']),
      muamalat: Map<String, String>.from(json['domains']['muamalat']),
    );
  }
}

class FiqhSources {
  final Map<String, String> title;
  final List<FiqhSourceItem> primary;
  final Map<String, String> secondary;

  FiqhSources({
    required this.title,
    required this.primary,
    required this.secondary,
  });

  factory FiqhSources.fromJson(Map<String, dynamic> json) {
    return FiqhSources(
      title: Map<String, String>.from(json['title']),
      primary: List<FiqhSourceItem>.from(
          json['primary'].map((e) => FiqhSourceItem.fromJson(e))),
      secondary: Map<String, String>.from(json['secondary']),
    );
  }
}

class FiqhSourceItem {
  final Map<String, String> name;
  final Map<String, String> description;

  FiqhSourceItem({
    required this.name,
    required this.description,
  });

  factory FiqhSourceItem.fromJson(Map<String, dynamic> json) {
    return FiqhSourceItem(
      name: Map<String, String>.from(json['name']),
      description: Map<String, String>.from(json['description']),
    );
  }
}

class FiqhSchools {
  final Map<String, String> title;
  final List<FiqhSchoolItem> list;

  FiqhSchools({
    required this.title,
    required this.list,
  });

  factory FiqhSchools.fromJson(Map<String, dynamic> json) {
    return FiqhSchools(
      title: Map<String, String>.from(json['title']),
      list: List<FiqhSchoolItem>.from(
          json['list'].map((e) => FiqhSchoolItem.fromJson(e))),
    );
  }
}

class FiqhSchoolItem {
  final Map<String, String> name;
  final Map<String, String> founder;
  final Map<String, String> feature;

  FiqhSchoolItem({
    required this.name,
    required this.founder,
    required this.feature,
  });

  factory FiqhSchoolItem.fromJson(Map<String, dynamic> json) {
    return FiqhSchoolItem(
      name: Map<String, String>.from(json['name']),
      founder: Map<String, String>.from(json['founder']),
      feature: Map<String, String>.from(json['feature']),
    );
  }
}
