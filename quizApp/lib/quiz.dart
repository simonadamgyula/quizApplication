import 'dart:convert';
import 'dart:developer';

import 'package:quiz_app/api.dart';
import 'package:quiz_app/authentication.dart';

class Quiz {
  Quiz({
    required this.name,
    required this.owner,
    required this.id,
    required this.maxPoints,
  });

  final int id;
  final String name;
  final String owner;
  final int maxPoints;
  List<Question> questions = [];

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
    log(json.toString());
    return switch (json) {
      {
        "id": String id,
        "name": String name,
        "user_id": String owner,
        "max_points": String maxPoints,
      } =>
        Quiz(
          name: name,
          owner: owner,
          id: int.parse(id),
          maxPoints: int.parse(maxPoints),
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
  final String question;
  final List<String> options;
  final int type;
  final int index;
  final String? answer;

  String get typeString {
    return switch (type) {
      0 => "True or False",
      1 => "Single choice",
      2 => "Multiple choice",
      3 => "Order",
      4 => "Number line",
      5 => "Multiple choice number line",
      6 => "Range",
      _ => "",
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    log(json.toString());
    return switch (json) {
      {
        "id": String id,
        "quiz_id": String quizId,
        "question": String question,
        "type": String type,
        "options": List<dynamic> options,
        "index": String index,
        "answer": String answer,
      } =>
        Question(
            id: int.parse(id),
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
