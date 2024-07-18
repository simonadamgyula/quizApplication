import 'package:flutter/material.dart';
import 'package:quiz_app/authentication.dart';
import 'package:quiz_app/pages/question.dart';

import '../quiz.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.quiz});

  final Quiz quiz;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Future<bool> _futureGetQuestions(Quiz quiz) async {
    await quiz.loadQuestions();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final Future<bool> futureLoadQuestions = _futureGetQuestions(widget.quiz);

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      appBar: AppBar(
        backgroundColor: const Color(0xff000000),
        foregroundColor: Colors.white,
        title: const Text(""),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              widget.quiz.name,
              style: const TextStyle(color: Colors.white),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionPage(
                      quiz: widget.quiz,
                      question: widget.quiz.questions[0],
                      answers: Answer(
                          user: Session().getToken()!,
                          length: widget.quiz.questions.length),
                      index: 0,
                    ),
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
                    return const CircularProgressIndicator(color: Colors.white);
                  }

                  return const Text("Fill out");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
