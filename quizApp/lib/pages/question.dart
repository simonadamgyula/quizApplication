import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../style.dart';
import '../quiz.dart';
import 'finished_quiz.dart';

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
  List<String> options = [];

  @override
  void initState() {
    options = widget.question.options;
    if (widget.question.type != 4) {
      options.shuffle();
    }
    super.initState();
  }

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
          options: options,
          callback: callback,
        ),
      2 => MultipleChoiceQuestion(
          options: options,
          callback: callback,
        ),
      3 => ReorderQuestion(
          options: options,
          callback: callback,
        ),
      4 => NumberLineQuestion(
          options: options,
          callback: callback,
        ),
      _ => throw UnimplementedError(),
    };
  }

  void endQuiz() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FinishedQuizPage(quiz: widget.quiz, answers: widget.answers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final options = getOptions();

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      appBar: AppBar(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        title: Text(
          widget.quiz.name,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Confirm quit"),
                content: const Text(
                  "Are you sure you want to quit?\n(This will submit your answers)",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      endQuiz();
                    },
                    child: const Text(
                      "Quit",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 10,
              ),
              child: Text(
                widget.question.question,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            options,
            IconButton(
              onPressed: () {
                widget.answers.addAnswer(widget.question.id, answer ?? "");
                if (widget.index + 1 == widget.quiz.questions.length) {
                  log(widget.answers.answers.toString());
                  endQuiz();
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
        padding: const EdgeInsets.all(20),
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
              backgroundColor: colors[index],
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
              backgroundColor: colors[index],
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

  Map<String, Color> colorMap = {};

  @override
  void initState() {
    options = widget.options;
    for (var i = 0; i < options!.length; i++) {
      colorMap[options![i]] = colors[i];
    }

    super.initState();
  }

  Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          color: Colors.transparent,
          shadowColor: Colors.black.withOpacity(0.7),
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ReorderableListView(
        padding: const EdgeInsets.all(20),
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final String item = options!.removeAt(oldIndex);
            options!.insert(newIndex, item);
          });

          log(options.toString());
          widget.callback(options!.join(","));
        },
        proxyDecorator: proxyDecorator,
        children: widget.options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;

          return Card(
            key: ValueKey(index),
            color: colorMap[option],
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    option,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ReorderableDragStartListener(
                    index: index,
                    child: const Icon(
                      Icons.drag_handle,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class NumberLineQuestion extends StatefulWidget {
  const NumberLineQuestion({
    super.key,
    required this.options,
    required this.callback,
  });

  final List<String> options;
  final void Function(String) callback;

  @override
  State<NumberLineQuestion> createState() => _NumberLineQuestionState();
}

class _NumberLineQuestionState extends State<NumberLineQuestion> {
  double sliderValue = 0;

  double sliderMin = 0;
  double sliderMax = 0;
  double sliderStep = 0;

  @override
  void initState() {
    log(widget.options.toString());
    sliderMin = double.parse(widget.options[0]);
    sliderMax = double.parse(widget.options[1]);
    sliderStep = double.parse(widget.options[2]);
    setState(() {
      sliderValue = sliderMin;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int? divisions =
        sliderStep == 0 ? null : ((sliderMax - sliderMin) / sliderStep).round();

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 15.0,
        trackShape: const RoundedRectSliderTrackShape(),
        activeTrackColor: colors[1],
        inactiveTrackColor: accentColor,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 14,
        ),
        thumbColor: Colors.white,
        overlayColor: Colors.white.withOpacity(0.1),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 4),
        activeTickMarkColor: invertColor(accentColor),
        inactiveTickMarkColor: invertColor(accentColor).withOpacity(0.2),
        valueIndicatorShape: const RectangularSliderValueIndicatorShape(),
        valueIndicatorColor: Colors.grey.shade900,
        valueIndicatorTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
      child: Slider(
        value: sliderValue,
        min: sliderMin,
        max: sliderMax,
        divisions: divisions,
        label: sliderValue.toStringAsFixed(1),
        onChanged: (value) {
          setState(() {
            sliderValue = value;
          });
        },
        onChangeEnd: (value) {
          widget.callback(value.toStringAsFixed(1));
        },
      ),
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
