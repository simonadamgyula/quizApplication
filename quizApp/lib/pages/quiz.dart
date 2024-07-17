import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:quiz_app/api.dart';
import 'package:quiz_app/authentication.dart';
import 'package:quiz_app/pages/question.dart';

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
      log(response.statusCode.toString());
      return null;
    }

    final body = jsonDecode(response.body);
    return Quiz.fromJson(body);
  }
  
  Future<bool> _futureGetQuestions(Quiz quiz) async {
    await quiz.loadQuestions();
    log(quiz.questions.toString());
    return true;
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
          final Future<bool> futureLoadQuestions = _futureGetQuestions(quiz);

          return Scaffold(
              appBar: AppBar(
                title: const Text(""),
              ),
              body: Center(
                child: Column(
                  children: [
                    Text(quiz.name),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                QuestionPage(question: quiz.questions[0]),
                          ),
                        );
                      },
                      child: FutureBuilder<bool>(
                        future: futureLoadQuestions,
                        builder: (context, AsyncSnapshot<bool> snapshot) {
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }

                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator(
                                color: Colors.white);
                          }

                          return const Text("Fill out");
                        },
                      ),
                    ),
                  ],
                ),
              ));
        });
  }
}
