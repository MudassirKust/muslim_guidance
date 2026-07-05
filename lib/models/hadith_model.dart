// models/hadith_model.dart
class HadithBook {
  final String id;
  final Map<String, String> title;
  final Map<String, String> sectionTitle;
  final Map<String, String> content;

  HadithBook({
    required this.id,
    required this.title,
    required this.sectionTitle,
    required this.content,
  });

  factory HadithBook.fromJson(String id, Map<String, dynamic> json) {
    return HadithBook(
      id: id,
      title: Map<String, String>.from(json['title'] ?? {}),
      sectionTitle: Map<String, String>.from(json['section_title'] ?? {}),
      content: Map<String, String>.from(json['content'] ?? {}),
    );
  }
}

class HadithCollection {
  final Map<String, HadithBook> books;

  HadithCollection({required this.books});

  factory HadithCollection.fromJson(Map<String, dynamic> json) {
    final books = <String, HadithBook>{};
    json.forEach((key, value) {
      books[key] = HadithBook.fromJson(key, value);
    });
    return HadithCollection(books: books);
  }
}
