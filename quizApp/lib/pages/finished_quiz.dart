import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../api.dart';
import '../authentication.dart';
import '../colors.dart';
import '../detailed_answers.dart';
import '../quiz.dart';

class FinishedQuizPage extends StatelessWidget {
  const FinishedQuizPage(
      {super.key, required this.quiz, required this.answers});

  final Quiz quiz;
  final Answer answers;

  Future<Map<String, dynamic>> _submitAnswers() async {
    log("submitting answers");
    final response = await sendApiRequest("/quiz/answers/create",
        {"quiz_id": quiz.id, "answers": answers.answers},
        authToken: Session().getToken());

    if (response.statusCode != 200) {
      throw Exception(response.statusCode.toString());
    }

    final body = jsonDecode(utf8.decode(response.bodyBytes));
    return body;
  }

  @override
  Widget build(BuildContext context) {
    final futureScore = _submitAnswers();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        title: Text(
          quiz.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: futureScore,
            builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              if (!snapshot.hasData) {
                return const CircularProgressIndicator(color: Colors.white);
              }

              final Map<String, dynamic> data = snapshot.data!;
              final scoreEarned = data["score"];
              final details = data["details"];

              log(details.toString());

              return Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "You have earned:",
                          style: TextStyle(
                            color: CupertinoColors.systemGrey2,
                            fontSize: 30,
                          ),
                        ),
                        Text(
                          "${scoreEarned.toString().replaceAll(RegExp(r'([.]*0)(?!.*\d)'), "")} / ${quiz.maxPoints}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${((scoreEarned / quiz.maxPoints) * 100).toString().replaceAll(RegExp(r'([.]*0)(?!.*\d)'), "")}%",
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                            fontSize: 35,
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: const BorderSide(
                              width: 2,
                              color: Colors.white,
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SingleChildScrollView(
                          child: DetailedAnswers(
                            details: details,
                            quiz: quiz,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
