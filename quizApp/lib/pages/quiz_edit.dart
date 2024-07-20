import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/api.dart';

import '../authentication.dart';
import '../quiz.dart';

class QuizEditPage extends StatefulWidget {
  const QuizEditPage({super.key, required this.id});

  final int id;

  @override
  State<QuizEditPage> createState() => _QuizEditPageState();
}

class _QuizEditPageState extends State<QuizEditPage> {
  final TextEditingController nameController = TextEditingController();
  Future<Quiz>? _futureQuiz;

  Future<Quiz> _getQuiz() async {
    final response = await sendApiRequest(
      "/quiz/get_owned",
      {
        "id": widget.id,
      },
      authToken: Session().getToken(),
    );

    if (response.statusCode != 200) {
      throw Exception(response.statusCode.toString());
    }

    final body = jsonDecode(response.body);
    return Quiz.fromJson(body);
  }

  @override
  void initState() {
    setState(() {
      _futureQuiz = _getQuiz();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x00000000),
      appBar: AppBar(
        backgroundColor: const Color(0xff000000),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Quiz>(
        future: _futureQuiz,
        builder: (context, AsyncSnapshot<Quiz> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                children: [
                  const Text("Unable to edit this quiz."),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Back"),
                  )
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          final quiz = snapshot.data!;
          nameController.text = quiz.name;

          return Column(
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
              ),
              Questions(quiz: quiz)
            ],
          );
        },
      ),
    );
  }
}

class Questions extends StatelessWidget {
  const Questions({super.key, required this.quiz});

  final Quiz quiz;

  Future<bool> _futureGetQuestions(Quiz quiz) async {
    await quiz.loadQuestions();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final futureQuestions = _futureGetQuestions(quiz);

    return FutureBuilder(
      future: futureQuestions,
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasError) {
          return const Text(
            "Unable to load questions",
            style: TextStyle(
              color: Colors.white,
            ),
          );
        }
        if (!snapshot.hasData) {
          return const CircularProgressIndicator(
            color: Colors.white,
          );
        }

        return Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: quiz.questions
                  .map((question) => QuestionPreview(question: question))
                  .toList()),
        );
      },
    );
  }
}

class QuestionPreview extends StatelessWidget {
  const QuestionPreview({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            question.question,
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }
}
