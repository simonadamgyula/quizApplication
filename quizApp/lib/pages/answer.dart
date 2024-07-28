import 'package:flutter/material.dart';
import 'package:quim/detailed_answers.dart';
import 'package:quim/quiz.dart';
import 'package:intl/intl.dart';

class AnswerPage extends StatelessWidget {
  const AnswerPage({
    super.key,
    required this.answer,
    required this.username,
    required this.details,
    required this.quiz,
  });

  final Quiz quiz;
  final RetrieveAnswer answer;
  final String username;
  final Map<String, dynamic> details;

  @override
  Widget build(BuildContext context) {
    DateTime answeredAt = DateTime.parse(answer.answeredAt);
    DateFormat dateFormat = DateFormat("yyyy-MM-dd H:m:s");

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          RichText(
            text: TextSpan(
              text: "Answered by ",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
              children: [
                TextSpan(
                    text: username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ))
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              text: "at ",
              children: [
                TextSpan(
                  text: dateFormat.format(answeredAt),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text("${answer.scoreEarned}/${quiz.maxPoints}"),
          DetailedAnswers(
            details: details,
            quiz: quiz,
          ),
        ],
      ),
    );
  }
}
