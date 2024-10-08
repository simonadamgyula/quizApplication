import 'dart:convert';
import 'dart:developer';

import 'package:quim/pages/question_edit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';

import '../api.dart';
import '../authentication.dart';
import '../style.dart';
import '../quiz.dart';
import 'answers.dart';

extension on String {
  List<String> splitInHalf() =>
      [substring(0, (length / 2).floor()), substring((length / 2).floor())];
}

class QuizEditPage extends StatefulWidget {
  const QuizEditPage({super.key, required this.id});

  final int id;

  @override
  State<QuizEditPage> createState() => _QuizEditPageState();
}

class _QuizEditPageState extends State<QuizEditPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<Quiz>? _futureQuiz;

  bool deleting = false;
  Quiz? quiz;

  void updateMaxScore() {
    if (quiz == null) return;

    int maxScore = 0;

    for (var question in quiz!.questions) {
      switch (question.type) {
        case 0:
        case 1:
        case 4:
          maxScore++;
          break;
        case 2:
          maxScore += question.answer?.split(",").length ?? 0;
          break;
        case 3:
          maxScore += question.options.length;
          break;
      }
    }

    sendApiRequest(
      "/quiz/set_max_score",
      {"id": quiz!.id, "max_score": maxScore},
      authToken: Session().getToken(),
    );
  }

  void updateCallback() {
    updateMaxScore();
    setState(() {});
  }

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

    final body = jsonDecode(utf8.decode(response.bodyBytes));
    setState(() {
      quiz = Quiz.fromJson(body);
    });
    return quiz!;
  }

  @override
  void initState() {
    _futureQuiz = _getQuiz();
    super.initState();
  }

  void showDeleteConfirmation() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "Confirm delete",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            content: const Text(
              "Are you sure you want to delete the quiz?",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: accentColor,
            actions: [
              TextButton(
                onPressed: () async {
                  setState(() {
                    deleting = true;
                  });

                  final response = await sendApiRequest(
                    "/quiz/delete",
                    {"id": widget.id},
                    authToken: Session().getToken(),
                  );

                  if (response.statusCode != 200) {
                    Fluttertoast.showToast(
                      msg: "Failed to delete quiz",
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 16,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                    );
                  }

                  if (!context.mounted) return;

                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: deleting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xff000000),
        foregroundColor: Colors.white,
        actions: (quiz != null
                ? <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnswersPage(
                              quiz: quiz!,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.leaderboard,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: accentColor,
                                title: const Text(
                                  "Share code",
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    text: "Your share code is:\n",
                                    style: const TextStyle(color: Colors.white),
                                    children: [
                                      TextSpan(
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            Clipboard.setData(
                                              ClipboardData(text: quiz!.code),
                                            ).then((_) {
                                              Fluttertoast.showToast(
                                                msg: "Copied to clipboard!",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                              );
                                            });
                                          },
                                        text:
                                            quiz!.code.splitInHalf().join("-"),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Close",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                                actionsPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                              );
                            });
                      },
                      icon: const Icon(
                        Icons.share,
                        color: Colors.white,
                      ),
                    )
                  ]
                : <Widget>[const SizedBox()]) +
            [
              IconButton(
                onPressed: () async {
                  showDeleteConfirmation();
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
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

          nameController.text = quiz!.name;
          descriptionController.text = quiz!.description ?? "";

          final color = Color(quiz!.color);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.crop_square_rounded,
                    color: color,
                  ),
                ),
                TextField(
                  controller: nameController,
                  style: const TextStyle(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: (Colors.grey).withOpacity(0.1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: descriptionController,
                  maxLines: null,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: "Description",
                    hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.9),
                      fontStyle: FontStyle.italic,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: (Colors.grey).withOpacity(0.1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.withOpacity(0.1),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Questions(quiz: quiz!, callback: updateCallback)
              ],
            ),
          );
        },
      ),
    );
  }
}

class Questions extends StatelessWidget {
  const Questions({
    super.key,
    required this.quiz,
    required this.callback,
  });

  final Quiz quiz;
  final void Function() callback;

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
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
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
                                  callback: callback,
                                ) as Widget)
                            .toList()) +
                        <Widget>[
                          AddQuestionButton(
                            quiz: quiz,
                            callback: callback,
                          )
                        ],
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
  const AddQuestionButton(
      {super.key, required this.quiz, required this.callback});

  final Quiz quiz;
  final void Function() callback;

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

    final body = jsonDecode(utf8.decode(response.bodyBytes));
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
              builder: (context) => QuestionEditPage(
                quiz: widget.quiz,
                question: question,
              ),
              settings: const RouteSettings(name: "question_edit"),
            ),
          ).then((_) => widget.callback());
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
                color: accentColor,
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
  const QuestionPreview({
    super.key,
    required this.question,
    required this.quiz,
    required this.callback,
  });

  final Quiz quiz;
  final Question question;
  final void Function() callback;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                QuestionEditPage(quiz: quiz, question: question),
            settings: const RouteSettings(name: "question_edit"),
          ),
        ).then((_) => callback());
      },
      child: Container(
        height: 60,
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(
            color: accentColor,
            width: 2,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: accentColor,
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
