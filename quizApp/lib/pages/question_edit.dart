import 'package:flutter/material.dart';

import '../quiz.dart';

class QuestionEditPage extends StatelessWidget {
  const QuestionEditPage({
    super.key,
    required this.quiz,
    required this.question,
  });

  final Quiz quiz;
  final Question question;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          quiz.name,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff181b23),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          MaterialButton(
            onPressed: () {},
            child: Row(
              children: [
                Text(question.typeString),
              ],
            ),
          )
        ],
      ),
    );
  }
}
