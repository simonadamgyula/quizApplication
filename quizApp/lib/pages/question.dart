import 'dart:developer';

import 'package:flutter/material.dart';

import '../quiz.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage(
      {super.key,
      required this.question,
      required this.index,
      required this.quiz,
      required this.answers});

  final Quiz quiz;
  final Question question;
  final Answer answers;
  final int index;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  String? answer;

  void callback(String answer) {
    setState(() {
      this.answer = answer;
    });
  }

  Widget getOptions() {
    return switch (widget.question.type) {
      0 => TFQuestion(
          callback: callback,
        ),
      _ => throw UnimplementedError(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final options = getOptions();

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      appBar: AppBar(
        backgroundColor: const Color(0xff181b23),
        foregroundColor: Colors.white,
        title: Text(
          widget.quiz.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              widget.question.question,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              widget.question.options.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            options,
            IconButton(
              onPressed: () {
                widget.answers.addAnswer(widget.question.id, answer ?? "");
                if (widget.index + 1 == widget.quiz.questions.length) {
                  log(widget.answers.answers.toString());
                  Navigator.pop(context);
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionPage(
                        question: widget.quiz.questions[widget.index + 1],
                        index: widget.index + 1,
                        quiz: widget.quiz,
                        answers: widget.answers),
                  ),
                );
              },
              icon: const Icon(
                Icons.arrow_right,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TFQuestion extends StatefulWidget {
  const TFQuestion({super.key, required this.callback});

  final Function callback;

  @override
  State<TFQuestion> createState() => _TFQuestionState();
}

class _TFQuestionState extends State<TFQuestion> {
  bool? selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            setState(() {
              selected = true;
            });
            widget.callback(selected.toString());
          },
          style: TextButton.styleFrom(
              backgroundColor:
                  (selected != null && selected!) ? Colors.green : Colors.red),
          child: const Text(
            "True",
            style: TextStyle(color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              selected = false;
            });
            widget.callback(selected.toString());
          },
          style: TextButton.styleFrom(
              backgroundColor:
                  (selected != null && !selected!) ? Colors.green : Colors.red),
          child: const Text(
            "False",
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }
}
