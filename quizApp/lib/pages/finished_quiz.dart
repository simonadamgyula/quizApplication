import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:quiz_app/api.dart';

import '../authentication.dart';
import '../quiz.dart';

class FinishedQuizPage extends StatelessWidget {
  const FinishedQuizPage(
      {super.key, required this.quiz, required this.answers});

  final Quiz quiz;
  final Answer answers;

  Future<double> submitAnswers() async {
    log("submitting answers");
    final response = await sendApiRequest("/quiz/answers/create",
        {"quiz_id": quiz.id, "answers": answers.answers},
        authToken: Session().getToken());

    if (response.statusCode != 200) {
      throw Exception(response.statusCode.toString());
    }

    final body = jsonDecode(response.body);
    return body["score"];
  }

  @override
  Widget build(BuildContext context) {
    final futureScore = submitAnswers();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xff181b23),
        foregroundColor: Colors.white,
        title: Text(
          quiz.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Text(answers.answers.toString()),
          FutureBuilder(
            future: futureScore,
            builder: (context, AsyncSnapshot<double> snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator(color: Colors.white);
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              return Text(snapshot.data.toString());
            },
          ),
        ],
      ),
    );
  }
}
