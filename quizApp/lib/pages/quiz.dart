import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quiz_app/api.dart';
import 'package:quiz_app/authentication.dart';

import '../quiz.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.code});

  final String code;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Future<Quiz?> _getFutureQuiz(String code) async {
    final response = await sendApiRequest("/quiz/get", {"code": code},
        authToken: Session().getToken());

    if (response.statusCode != 200) {
      return null;
    }

    final body = jsonDecode(response.body);
    return Quiz.fromJson(body);
  }

  @override
  Widget build(BuildContext context) {
    final futureQuiz = _getFutureQuiz(widget.code);
    return FutureBuilder(
        future: futureQuiz,
        builder: (BuildContext context, AsyncSnapshot<Quiz?> snapshot) {
          if (!snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: const Text("Loading..."),
              ),
              body: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            );
          }

          final Quiz quiz = snapshot.data!;

          return Scaffold(
              appBar: AppBar(
                title: Text(quiz.name),
              ),
              body: Center(
                child: Text(quiz.id.toString()),
              ));
        });
  }
}
