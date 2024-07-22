import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quiz_app/api.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:quiz_app/pages/question_edit.dart';

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
              const SizedBox(
                height: 40,
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
          return Text(
            "Unable to load questions: ${snapshot.error.toString()}",
            style: const TextStyle(
              color: Colors.white,
            ),
          );
        }
        if (!snapshot.hasData) {
          return const CircularProgressIndicator(
            color: Colors.white,
          );
        }

        return Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Questions",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 30),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: (quiz.questions
                            .map((question) => QuestionPreview(
                                  question: question,
                                  quiz: quiz,
                                ) as Widget)
                            .toList()) +
                        <Widget>[AddQuestionButton(quiz: quiz)],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddQuestionButton extends StatefulWidget {
  const AddQuestionButton({super.key, required this.quiz});

  final Quiz quiz;

  @override
  State<AddQuestionButton> createState() => _AddQuestionButtonState();
}

class _AddQuestionButtonState extends State<AddQuestionButton> {
  bool loading = false;

  Future<Question?> _createNewQuestion() async {
    final response = await sendApiRequest(
      "/quiz/questions/create",
      {
        "quiz_id": widget.quiz.id,
        "question": "",
        "answer": "",
        "options": [],
        "type": 0,
        "index": widget.quiz.questions.length,
      },
      authToken: Session().getToken(),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final body = jsonDecode(response.body);
    return Question.fromJson({
      "id": body["id"],
      "quiz_id": widget.quiz.id.toString(),
      "question": "",
      "answer": "",
      "options": [],
      "type": "0",
      "index": widget.quiz.questions.length.toString(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        setState(() {
          loading = true;
        });

        final Question? question = await _createNewQuestion();

        if (question != null && context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  QuestionEditPage(quiz: widget.quiz, question: question),
            ),
          );
        }

        setState(() {
          loading = false;
        });
      },
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(15),
        decoration: const BoxDecoration(
          border: DashedBorder.fromBorderSide(
              side: BorderSide(
                color: Color(0xff181b23),
                width: 4,
              ),
              dashLength: 10),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Center(
          child: loading
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}

class QuestionPreview extends StatelessWidget {
  const QuestionPreview(
      {super.key, required this.question, required this.quiz});

  final Quiz quiz;
  final Question question;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                QuestionEditPage(quiz: quiz, question: question),
          ),
        );
      },
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xff181b23),
            width: 2,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: const Color(0xff181b23),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              question.question,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}
