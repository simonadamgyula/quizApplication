import 'dart:convert';
import 'dart:developer';

import 'package:quiz_app/api.dart';

class Quiz {
  Quiz({required this.name, required this.owner, required this.id});

  final int id;
  final String name;
  final String owner;
  List<Question> questions = [];

  Future<void> loadQuestions() async {
    final response = await sendApiRequest(
      "/quiz/questions/get",
      {
        "id": id,
      },
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
        "id": String id,
        "name": String name,
        "user_id": String owner,
      } =>
        Quiz(
          name: name,
          owner: owner,
          id: int.parse(id),
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
    required this.answer,
    required this.type,
    required this.index,
  });

  final int id;
  final int quizId;
  final String question;
  final List<String> options;
  final String answer;
  final int type;
  final int index;

  factory Question.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        "id": String id,
        "quiz_id": String quizId,
        "question": String question,
        "type": String type,
        "answer": String answer,
        "options": List<dynamic> options,
        "index": String index
      } =>
        Question(
          id: int.parse(id),
          quizId: int.parse(quizId),
          question: question,
          type: int.parse(type),
          answer: answer,
          options: List<String>.from(options),
          index: int.parse(index),
        ),
      _ => throw const FormatException('Failed to load quiz.'),
    };
  }
}

class Answer {
  Answer({required this.user, required this.length});

  final String user;
  final int length;
  Map<int, String> answers = {};

  void addAnswer(int id, String answer) {
    answers[id] = answer;
  }
}
