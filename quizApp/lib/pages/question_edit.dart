import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:quiz_app/api.dart';

import '../authentication.dart';
import '../quiz.dart';

const List<Color> colors = [
  Colors.red,
  Colors.blueAccent,
  Color(0xFFDDC400),
  Colors.green,
  Colors.purple,
  Colors.deepOrangeAccent
];

class QuestionEditPage extends StatefulWidget {
  const QuestionEditPage({
    super.key,
    required this.quiz,
    required this.question,
  });

  final Quiz quiz;
  final Question question;

  @override
  State<QuestionEditPage> createState() => _QuestionEditPageState();
}

class _QuestionEditPageState extends State<QuestionEditPage> {
  int type = 0;

  final TextEditingController questionController = TextEditingController();

  @override
  void initState() {
    setState(() {
      type = widget.question.type;
      questionController.text = widget.question.question;
    });
    super.initState();
  }

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  void typeSelectCallback(int value) {
    widget.question.type = value;
    setState(() {
      type = value;
    });
    Navigator.pop(context);
    editQuestion().catchError((error) {
      log(error.toString());
    });
  }

  Widget getOptions() {
    return switch (widget.question.type) {
      0 => TFOptions(
          question: widget.question,
          updater: editQuestion,
        ),
      1 => SingleChoiceOptions(
          question: widget.question,
          updater: editQuestion,
        ),
      2 => MultipleChoiceOptions(
          question: widget.question,
          updater: editQuestion,
        ),
      3 => ReorderOptions(
          question: widget.question,
          updater: editQuestion,
        ),
      _ => const SizedBox(),
    };
  }

  Future<void> editQuestion() async {
    final response = await sendApiRequest(
      "/quiz/questions/edit",
      {
        "id": widget.question.id,
        "question": widget.question.question,
        "answer": widget.question.answer,
        "options": widget.question.options,
        "type": widget.question.type,
      },
      authToken: Session().getToken(),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Error while updating question: ${response.statusCode.toString()}");
    }
  }

  void showTypeSelect() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            crossAxisCount: 3,
            children: [
              TypeSelectButton("True or false",
                  callback: typeSelectCallback,
                  icon: Icons.indeterminate_check_box_sharp,
                  value: 0),
              TypeSelectButton("Single choice",
                  callback: typeSelectCallback,
                  icon: Icons.indeterminate_check_box_sharp,
                  value: 1),
              TypeSelectButton("Multiple choice",
                  callback: typeSelectCallback,
                  icon: Icons.indeterminate_check_box_sharp,
                  value: 2),
              TypeSelectButton("Reorder",
                  callback: typeSelectCallback,
                  icon: Icons.indeterminate_check_box_sharp,
                  value: 3),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.quiz.name,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff181b23),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          TextField(
            controller: questionController,
            decoration: const InputDecoration(
              hintText: "Question",
              hintStyle: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            style: const TextStyle(
              color: Colors.white,
            ),
            onEditingComplete: () {
              widget.question.question = questionController.text;
              editQuestion().catchError((error) {
                log(error.toString());
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: MaterialButton(
              onPressed: () {
                showTypeSelect();
              },
              padding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                side: const BorderSide(
                  color: Colors.white,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    widget.question.typeString,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Icon(
                    Icons.indeterminate_check_box_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          getOptions(),
        ],
      ),
    );
  }
}

class TypeSelectButton extends StatelessWidget {
  const TypeSelectButton(this.text,
      {super.key,
      required this.callback,
      required this.icon,
      required this.value});

  final String text;
  final void Function(int) callback;
  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        callback(value);
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(text),
          Icon(icon),
        ],
      ),
    );
  }
}

class TFOptions extends StatefulWidget {
  const TFOptions({super.key, required this.question, required this.updater});

  final Question question;
  final Future<void> Function() updater;

  @override
  State<TFOptions> createState() => _TFOptionsState();
}

class _TFOptionsState extends State<TFOptions> {
  String answer = "";

  @override
  void initState() {
    setState(() {
      answer = widget.question.answer!;
    });
    super.initState();
  }

  void buttonPressCallback(String answer) {
    log(answer);
    widget.question.answer = answer;
    setState(() {
      this.answer = answer;
    });
    widget.updater();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
        primary: false,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        padding: const EdgeInsets.all(20.0),
        crossAxisCount: 2,
        children: [
          OptionButton(
            "True",
            onPressed: () => buttonPressCallback("true"),
            backgroundColor: Colors.blueAccent,
            selected: widget.question.answer == "true",
          ),
          OptionButton(
            "False",
            onPressed: () => buttonPressCallback("false"),
            backgroundColor: Colors.redAccent,
            selected: widget.question.answer == "false",
          ),
        ],
      ),
    );
  }
}

class SingleChoiceOptions extends StatefulWidget {
  const SingleChoiceOptions(
      {super.key, required this.question, required this.updater});

  final Question question;
  final Future<void> Function() updater;

  @override
  State<SingleChoiceOptions> createState() => _SingleChoiceOptionsState();
}

class _SingleChoiceOptionsState extends State<SingleChoiceOptions> {
  String answer = "";
  List<String> options = [];

  @override
  void initState() {
    setState(() {
      answer = widget.question.answer!;
      options = widget.question.options;
    });
    super.initState();
  }

  void buttonPressCallback(String answer) {
    if (answer.isEmpty) return;

    widget.question.answer = answer;
    setState(() {
      this.answer = answer;
    });
    widget.updater();
  }

  void addOption() {
    setState(() {
      options.add("");
    });
  }

  void removeOptionCallback(int index) {
    setState(() {
      options.removeAt(index);
    });
    widget.updater();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
        primary: false,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        padding: const EdgeInsets.all(20.0),
        crossAxisCount: 2,
        children: widget.question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return EditableOptionButton(
                option,
                onPressed: () => buttonPressCallback(option),
                backgroundColor: colors[index],
                selected: widget.question.answer == option && option.isNotEmpty,
                onEdited: (String value) {
                  if (value.isEmpty) return;
                  setState(() {
                    options[index] = value;
                  });
                  widget.updater();
                },
                index: index,
                removeCallback: removeOptionCallback,
              ) as Widget;
            }).toList() +
            [
              options.length < 6
                  ? Container(
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        border: DashedBorder.fromBorderSide(
                            side: BorderSide(
                              color: Color(0xff181b23),
                              width: 4,
                            ),
                            dashLength: 10),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: IconButton(
                        onPressed: () {
                          addOption();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add,
                          color: Color(0xff181b23),
                          size: 60,
                        ),
                      ),
                    )
                  : const SizedBox()
            ],
      ),
    );
  }
}

class MultipleChoiceOptions extends StatefulWidget {
  const MultipleChoiceOptions(
      {super.key, required this.question, required this.updater});

  final Question question;
  final Future<void> Function() updater;

  @override
  State<MultipleChoiceOptions> createState() => _MultipleChoiceOptionsState();
}

class _MultipleChoiceOptionsState extends State<MultipleChoiceOptions> {
  List<String> answers = [];
  List<String> options = [];

  @override
  void initState() {
    setState(() {
      answers = widget.question.answer!.split(",");
      options = widget.question.options;
    });
    super.initState();
  }

  void buttonPressCallback(String answer) {
    if (answer.isEmpty) return;

    setState(() {
      if (answers.contains(answer)) {
        answers.remove(answer);
      } else {
        answers.add(answer);
      }
    });
    widget.question.answer = answers.join(",");
    widget.updater();
  }

  void addOption() {
    setState(() {
      options.add("");
    });
  }

  void removeOptionCallback(int index) {
    String option = options[index];
    setState(() {
      options.removeAt(index);
      answers.remove(option);
    });
    widget.updater();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.count(
        primary: false,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        padding: const EdgeInsets.all(20.0),
        crossAxisCount: 2,
        children: widget.question.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return EditableOptionButton(
                option,
                onPressed: () => buttonPressCallback(option),
                backgroundColor: colors[index],
                selected: answers.contains(option) && option.isNotEmpty,
                onEdited: (String value) {
                  if (value.isEmpty) return;
                  setState(() {
                    options[index] = value;
                  });
                  widget.updater();
                },
                index: index,
                removeCallback: removeOptionCallback,
              ) as Widget;
            }).toList() +
            [
              options.length < 6
                  ? Container(
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        border: DashedBorder.fromBorderSide(
                            side: BorderSide(
                              color: Color(0xff181b23),
                              width: 4,
                            ),
                            dashLength: 10),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: IconButton(
                        onPressed: () {
                          addOption();
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add,
                          color: Color(0xff181b23),
                          size: 60,
                        ),
                      ),
                    )
                  : const SizedBox()
            ],
      ),
    );
  }
}

class ReorderOptions extends StatefulWidget {
  const ReorderOptions({
    super.key,
    required this.question,
    required this.updater,
  });

  final Question question;
  final Future<void> Function() updater;

  @override
  State<ReorderOptions> createState() => _ReorderOptionsState();
}

class _ReorderOptionsState extends State<ReorderOptions> {
  List<String> options = [];

  @override
  void initState() {
    options = widget.question.options;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ReorderableListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          onReorder: (int oldIndex, int newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final String item = options.removeAt(oldIndex);
              options.insert(newIndex, item);
            });

            widget.question.answer = options.join(",");
            widget.updater();
          },
          proxyDecorator: proxyDecorator,
          children: widget.question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;

            final controller = TextEditingController();
            controller.text = option;

            return Card(
              key: ValueKey(index),
              color: colors[index],
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Option $index",
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        onEditingComplete: () {
                          final index = options.indexOf(option);
                          options[index] = controller.text;
                          widget.updater();
                        },
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
            ) as Widget;
          }).toList(),
        ),
        options.length < 6
            ? Container(
                key: const ValueKey("addOption"),
                margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 6),
                padding: const EdgeInsets.all(0),
                decoration: const BoxDecoration(
                  border: DashedBorder.fromBorderSide(
                      side: BorderSide(
                        color: Color(0xff181b23),
                        width: 4,
                      ),
                      dashLength: 10),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      options.add("");
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  icon: const Icon(
                    Icons.add,
                    color: Color(0xff181b23),
                    size: 30,
                  ),
                ),
              )
            : const SizedBox(),
      ],
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

class EditableOptionButton extends StatefulWidget {
  const EditableOptionButton(
    this.text, {
    super.key,
    required this.onPressed,
    required this.backgroundColor,
    required this.selected,
    required this.onEdited,
    required this.index,
    required this.removeCallback,
  });

  final String text;
  final void Function() onPressed;
  final void Function(String) onEdited;
  final void Function(int) removeCallback;
  final Color backgroundColor;
  final bool selected;
  final int index;

  @override
  State<EditableOptionButton> createState() => _EditableOptionButtonState();
}

class _EditableOptionButtonState extends State<EditableOptionButton> {
  final TextEditingController optionController = TextEditingController();

  @override
  void initState() {
    optionController.text = widget.text;
    super.initState();
  }

  @override
  void dispose() {
    optionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            backgroundColor: widget.backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          child: TextField(
            controller: optionController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintStyle: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
              hintText: "Option ${widget.index + 1}",
              border: InputBorder.none,
            ),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            onEditingComplete: () {
              log("Calling on edited");
              widget.onEdited(optionController.text);
            },
            textAlign: TextAlign.center,
            maxLines: null,
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: widget.selected
              ? const Icon(
                  Icons.check_circle_outline,
                  size: 25,
                  color: Colors.white,
                )
              : const SizedBox(),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              widget.removeCallback(widget.index);
            },
          ),
        )
      ],
    );
  }
}
