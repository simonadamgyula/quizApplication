import 'package:flutter/material.dart';

import '../quiz.dart';

class QuestionPage extends StatelessWidget {
  const QuestionPage({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: Column(
        children: [
          Text(question.question),
          Text(question.options.toString()),
        ],
      ),
    );
  }
}
