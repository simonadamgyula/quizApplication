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
      1 => SingleChoiceQuestion(
          options: widget.question.options,
          callback: callback,
        ),
      2 => MultipleChoiceQuestion(
          options: widget.question.options,
          callback: callback,
        ),
      3 => ReorderQuestion(
          options: widget.question.options,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
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
    return Expanded(
      child: GridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        children: [
          OptionButton(
            "True",
            onPressed: () {
              setState(() {
                selected = true;
              });
              widget.callback(selected.toString());
            },
            backgroundColor: Colors.blueAccent,
            selected: (selected != null && selected!),
          ),
          OptionButton(
            "False",
            onPressed: () {
              setState(() {
                selected = false;
              });
              widget.callback(selected.toString());
            },
            backgroundColor: Colors.red,
            selected: (selected != null && !selected!),
          ),
        ],
      ),
    );
  }
}

class SingleChoiceQuestion extends StatefulWidget {
  const SingleChoiceQuestion(
      {super.key, required this.options, required this.callback});

  final List<String> options;
  final Function callback;

  final List<Color> colors = const [
    Colors.red,
    Colors.blueAccent,
    Color(0xFFDDC400),
    Colors.green,
    Colors.purple,
    Colors.deepOrangeAccent
  ];

  @override
  State<SingleChoiceQuestion> createState() => _SingleChoiceQuestionState();
}

class _SingleChoiceQuestionState extends State<SingleChoiceQuestion> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
        primary: false,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        padding: const EdgeInsets.all(20.0),
        crossAxisCount: 2,
        children: widget.options.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final option = entry.value;

            return OptionButton(
              option,
              onPressed: () {
                setState(() {
                  selected = option;
                });
                widget.callback(selected);
              },
              backgroundColor: widget.colors[index],
              selected: option == selected,
            );
          },
        ).toList(),
      ),
    );
  }
}

class MultipleChoiceQuestion extends StatefulWidget {
  const MultipleChoiceQuestion(
      {super.key, required this.options, required this.callback});

  final List<String> options;
  final Function callback;

  final List<Color> colors = const [
    Colors.red,
    Colors.blueAccent,
    Color(0xFFDDC400),
    Colors.green,
    Colors.purple,
    Colors.deepOrangeAccent
  ];

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  List<String> selected = [];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
        primary: false,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        padding: const EdgeInsets.all(20.0),
        crossAxisCount: 2,
        children: widget.options.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final option = entry.value;

            return OptionButton(
              option,
              onPressed: () {
                setState(() {
                  if (selected.contains(option)) {
                    selected.remove(option);
                  } else {
                    selected.add(option);
                  }
                });
                widget.callback(selected.join(","));
              },
              backgroundColor: widget.colors[index],
              selected: selected.contains(option),
            );
          },
        ).toList(),
      ),
    );
  }
}

class ReorderQuestion extends StatefulWidget {
  const ReorderQuestion({
    super.key,
    required this.options,
    required this.callback,
  });

  final List<String> options;
  final Function callback;

  @override
  State<ReorderQuestion> createState() => _ReorderQuestionState();
}

class _ReorderQuestionState extends State<ReorderQuestion> {
  List<String>? options;

  @override
  void initState() {
    options = widget.options;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      children: [
        for (int index = 0; index < widget.options.length; index += 1)
          ListTile(
            key: Key("$index"),
            tileColor: Colors.red,
            title: Text(options![index]),
          )
      ],
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final String item = options!.removeAt(oldIndex);
          options!.insert(newIndex, item);
        });
      },
    );
  }
}

class OptionButton extends StatelessWidget {
  const OptionButton(
    this.text, {
    super.key,
    required this.onPressed,
    required this.backgroundColor,
    required this.selected,
  });

  final String text;
  final void Function() onPressed;
  final Color backgroundColor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            backgroundColor: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: selected
              ? const Icon(
                  Icons.check_circle_outline,
                  size: 25,
                  color: Colors.white,
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}
