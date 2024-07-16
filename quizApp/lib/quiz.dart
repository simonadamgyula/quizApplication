class Quiz {
  Quiz({required this.name, required this.owner, required this.id});

  final int id;
  final String name;
  final String owner;
  List<Question> questions = [];

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {"id": int id, "name": String name, "owner": String owner} =>
        Quiz(name: name, owner: owner, id: id),
      _ => throw const FormatException('Failed to load quiz.'),
    };
  }
}

class Question {
  Question({
    required this.id,
    required this.quizId,
    required this.question,
    required this.options,
    required this.answer,
    required this.type,
  });

  final int id;
  final int quizId;
  final String question;
  final List<String> options;
  final String answer;
  final int type;
}
