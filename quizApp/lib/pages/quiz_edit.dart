import 'package:flutter/material.dart';

import '../quiz.dart';

class QuizEditPage extends StatelessWidget {
  const QuizEditPage({super.key, required this.id});

  final int id;

  Future<Quiz> _getQuiz() async {
    final result =
  }

  @override
  Widget build(BuildContext context) {
    final futureQuiz = _getQuiz();

    return Scaffold(
      appBar: AppBar(),
      body: FutureBuilder<Quiz>(
        future: ,
        builder: (context, AsyncSnapshot<Quiz> snapshot) {
          if
        },
      ),
    )
  }

}