// models/quiz_question.dart
class QuizQuestion {
  //final int id;
  final Map<String, String> question;
  final Map<String, List<String>> options;
  final int answerIndex;

  QuizQuestion({
    //required this.id,
    required this.question,
    required this.options,
    required this.answerIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      //id: json['id'],
      question: Map<String, String>.from(json['question']),
      options: Map<String, List<String>>.from((json['options'])
          .map((key, value) => MapEntry(key, List<String>.from(value)))),
      answerIndex: json['answer_index'],
    );
  }
}
