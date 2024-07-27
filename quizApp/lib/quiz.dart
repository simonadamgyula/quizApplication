import 'dart:convert';
import 'dart:developer';

import 'api.dart';
import 'authentication.dart';

class Quiz {
  Quiz({
    required this.name,
    required this.owner,
    required this.id,
    required this.maxPoints,
    required this.color,
    required this.code,
  });

  final int id;
  final String name;
  final String owner;
  final int maxPoints;
  List<Question> questions = [];
  final int color;
  final String code;

  Future<void> loadQuestions() async {
    final response = await sendApiRequest(
      "/quiz/questions/get",
      {
        "id": id,
      },
      authToken: Session().getToken(),
    );

    if (response.statusCode != 200) {
      throw Exception("Couldn't load questions");
    }

    final body = jsonDecode(response.body) as List;
    log(body.toString());
    questions = body.map((question) {
      return Question.fromJson(question);
    }).toList();
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id": int id,
        "name": String name,
        "user_id": String owner,
        "max_points": int maxPoints,
        "color": int color,
        "code": String code,
      } =>
        Quiz(
          name: name,
          owner: owner,
          id: id,
          maxPoints: maxPoints,
          color: color,
          code: code,
        ),
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
    required this.type,
    required this.index,
    this.answer,
  });

  final int id;
  final int quizId;
  String question;
  List<String> options;
  int type;
  int index;
  String? answer;

  String get typeString {
    return switch (type) {
      0 => "True or False",
      1 => "Single choice",
      2 => "Multiple choice",
      3 => "Reorder",
      4 => "Number line",
      5 => "Multiple choice number line",
      6 => "Range",
      _ => "",
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    log(json["id"].runtimeType.toString());
    log(json["quiz_id"].runtimeType.toString());
    log(json["question"].runtimeType.toString());
    log(json["type"].runtimeType.toString());
    log(json["options"].runtimeType.toString());
    log(json["index"].runtimeType.toString());
    log(json["answer"].runtimeType.toString());

    return switch (json) {
      {
        "id": int id,
        "quiz_id": int quizId,
        "question": String question,
        "type": int type,
        "options": String options,
        "index": int index,
        "answer": String answer,
      } =>
        Question(
            id: id,
            quizId: quizId,
            question: question,
            type: type,
            options: List<String>.from(jsonDecode(options)),
            index: index,
            answer: answer),
      {
        "id": int id,
        "quiz_id": String quizId,
        "question": String question,
        "type": String type,
        "options": List<dynamic> options,
        "index": String index,
        "answer": String answer,
      } =>
        Question(
            id: id,
            quizId: int.parse(quizId),
            question: question,
            type: int.parse(type),
            options: List<String>.from(options),
            index: int.parse(index),
            answer: answer),
      {
        "id": String id,
        "quiz_id": String quizId,
        "question": String question,
        "type": String type,
        "options": List<dynamic> options,
        "index": String index
      } =>
        Question(
          id: int.parse(id),
          quizId: int.parse(quizId),
          question: question,
          type: int.parse(type),
          options: List<String>.from(options),
          index: int.parse(index),
        ),
      _ => throw const FormatException('Failed to load question.'),
    };
  }
}

class Answer {
  Answer({required this.user, required this.length});

  final String user;
  final int length;
  Map<String, String> answers = {};

  void addAnswer(int id, String answer) {
    answers[id.toString()] = answer;
  }
}
