import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/api.dart';

import '../authentication.dart';
import '../quiz.dart';

class FinishedQuizPage extends StatelessWidget {
  const FinishedQuizPage(
      {super.key, required this.quiz, required this.answers});

  final Quiz quiz;
  final Answer answers;

  Future<double> _submitAnswers() async {
    log("submitting answers");
    final response = await sendApiRequest("/quiz/answers/create",
        {"quiz_id": quiz.id, "answers": answers.answers},
        authToken: Session().getToken());

    if (response.statusCode != 200) {
      throw Exception(response.statusCode.toString());
    }

    final body = jsonDecode(response.body);
    return body["score"].toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final futureScore = _submitAnswers();

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
          FutureBuilder<double>(
            future: futureScore,
            builder: (context, AsyncSnapshot<double> snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              if (!snapshot.hasData) {
                return const CircularProgressIndicator(color: Colors.white);
              }

              final double scoreEarned = snapshot.data!;

              return Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "You have earned: ",
                      style: TextStyle(
                        color: CupertinoColors.systemGrey2,
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      "$scoreEarned / ${quiz.maxPoints}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${(scoreEarned / quiz.maxPoints) * 100}%",
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 35,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Continue"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
