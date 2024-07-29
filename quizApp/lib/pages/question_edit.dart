import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';

import '../api.dart';
import '../authentication.dart';
import '../style.dart';
import '../quiz.dart';

const Map<int, String> typeToIcon = {
  0: "assets/img/TF.svg",
  1: "assets/img/single choice.svg",
  2: "assets/img/multiple choice.svg",
  3: "assets/img/reorder.svg",
  4: "assets/img/reorder.svg",
};

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
  bool deleting = false;

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
    if (value == 4 || widget.question.type == 4) {
      widget.question.options = [];
      widget.question.answer = "";
    }
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
      4 => NumberLine(
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
      backgroundColor: accentColor,
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: GridView.count(
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            crossAxisCount: 3,
            children: [
              TypeSelectButton("True or false",
                  callback: typeSelectCallback,
                  icon: Icons.indeterminate_check_box_sharp,
                  iconPath: "assets/img/TF.svg",
                  value: 0),
              TypeSelectButton("Single choice",
                  callback: typeSelectCallback,
                  icon: Icons.indeterminate_check_box_sharp,
                  iconPath: "assets/img/single choice.svg",
                  value: 1),
              TypeSelectButton("Multiple choice",
                  callback: typeSelectCallback,
                  icon: Icons.indeterminate_check_box_sharp,
                  iconPath: "assets/img/multiple choice.svg",
                  value: 2),
              TypeSelectButton("Reorder",
                  callback: typeSelectCallback,
                  icon: Icons.indeterminate_check_box_sharp,
                  iconPath: "assets/img/reorder.svg",
                  value: 3),
              TypeSelectButton("Number line",
                  callback: typeSelectCallback,
                  icon: Icons.indeterminate_check_box_sharp,
                  iconPath: "assets/img/reorder.svg",
                  value: 4),
            ],
          ),
        );
      },
    );
  }

  Future<Response> deleteQuestion() async {
    return await sendApiRequest(
      "/quiz/questions/delete",
      {
        "id": widget.question.id,
      },
      authToken: Session().getToken(),
    );
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

                  final response = await deleteQuestion();

                  setState(() {
                    deleting = false;
                  });

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

                  Navigator.popUntil(
                    context,
                    ModalRoute.withName("quiz_edit"),
                  );
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
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.quiz.name,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDeleteConfirmation();
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          )
        ],
        leading: IconButton(
          onPressed: () async {
            if (widget.question.question.isEmpty) {
              await deleteQuestion();
            }

            if (!context.mounted) return;

            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 40,
        ),
        child: Column(
          children: [
            TextField(
              controller: questionController,
              decoration: InputDecoration(
                hintText: "Question",
                hintStyle: const TextStyle(
                  color: Colors.grey,
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
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: MaterialButton(
                onPressed: () {
                  showTypeSelect();
                },
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: (Colors.grey).withOpacity(0.2),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.question.typeString,
                        style: const TextStyle(color: Colors.white),
                      ),
                      SvgPicture.asset(typeToIcon[widget.question.type]!)
                    ],
                  ),
                ),
              ),
            ),
            getOptions(),
          ],
        ),
      ),
    );
  }
}

class TypeSelectButton extends StatelessWidget {
  const TypeSelectButton(
    this.text, {
    super.key,
    required this.callback,
    required this.icon,
    required this.value,
    required this.iconPath,
  });

  final String text;
  final void Function(int) callback;
  final IconData icon;
  final int value;
  final String iconPath;

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
        backgroundColor: const Color(0xff0a0a0a),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SvgPicture.asset(iconPath),
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
        physics: const ScrollPhysics(),
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
        physics: const ScrollPhysics(),
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
                              color: accentColor,
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
                          color: accentColor,
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
    log(widget.question.options.toString());
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
        physics: const ScrollPhysics(),
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
                              color: accentColor,
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
                          color: accentColor,
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
                        color: accentColor,
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
                    color: accentColor,
                    size: 30,
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}

class NumberLine extends StatefulWidget {
  const NumberLine({
    super.key,
    required this.question,
    required this.updater,
  });

  final Question question;
  final Future<void> Function() updater;

  @override
  State<NumberLine> createState() => _NumberLineState();
}

class _NumberLineState extends State<NumberLine> {
  double sliderValue = 0;
  double sliderMin = 0;
  double sliderMax = 100;
  double sliderStep = 10;

  TextEditingController minController = TextEditingController();
  TextEditingController maxController = TextEditingController();
  TextEditingController stepController = TextEditingController();

  void settingsListener() {
    setState(() {
      final sliderMinTemp = double.tryParse(minController.text) ?? 0;
      final sliderMaxTemp = double.tryParse(maxController.text) ?? 100;
      if (sliderMinTemp < sliderMaxTemp) {
        sliderMin = sliderMinTemp;
        sliderMax = sliderMaxTemp;
      }
      sliderStep = double.tryParse(stepController.text) ?? 10;

      if (sliderValue < sliderMin) {
        sliderValue = sliderMin;
      }
      if (sliderValue > sliderMax) {
        sliderValue = sliderMax;
      }
    });

    widget.question.options = [
      sliderMin.toStringAsFixed(1),
      sliderMax.toStringAsFixed(1),
      sliderStep.toStringAsFixed(1),
    ];
  }

  @override
  void initState() {
    if (widget.question.options.length == 3) {
      minController.text = widget.question.options[0];
      maxController.text = widget.question.options[1];
      stepController.text = widget.question.options[2];
    } else {
      minController.text = "0";
      maxController.text = "100";
      stepController.text = "10";
    }

    minController.addListener(settingsListener);
    maxController.addListener(settingsListener);
    stepController.addListener(settingsListener);

    settingsListener();
    super.initState();
  }

  @override
  void dispose() {
    minController.dispose();
    maxController.dispose();
    stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int? divisions =
        sliderStep == 0 ? null : ((sliderMax - sliderMin) / sliderStep).round();
    divisions = divisions == 0 ? null : divisions;

    if (divisions != null &&
        divisions != (sliderMax - sliderMin) / sliderStep) {
      setState(() {
        sliderMax = ((sliderMax - sliderMin) / sliderStep).ceil() * sliderStep;
      });
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: minController,
            decoration: InputDecoration(
              labelText: "Slider minimum",
              labelStyle: const TextStyle(
                color: Colors.white,
              ),
              border: inputBorder,
              focusedBorder: inputBorder,
              enabledBorder: inputBorder,
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d?'))
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextField(
              controller: maxController,
              decoration: InputDecoration(
                labelText: "Slider maximum",
                labelStyle: const TextStyle(
                  color: Colors.white,
                ),
                border: inputBorder,
                focusedBorder: inputBorder,
                enabledBorder: inputBorder,
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Colors.white,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d?'))
              ],
            ),
          ),
          TextField(
            controller: stepController,
            decoration: InputDecoration(
              labelText: "Slider step",
              labelStyle: const TextStyle(
                color: Colors.white,
              ),
              border: inputBorder,
              focusedBorder: inputBorder,
              enabledBorder: inputBorder,
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: Colors.white,
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^(\d+)?\.?\d?'))
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: SliderTheme(
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
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 10.0),
                tickMarkShape:
                    const RoundSliderTickMarkShape(tickMarkRadius: 4),
                activeTickMarkColor: invertColor(accentColor),
                inactiveTickMarkColor:
                    invertColor(accentColor).withOpacity(0.2),
                valueIndicatorShape:
                    const RectangularSliderValueIndicatorShape(),
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
                label: sliderValue
                    .toStringAsFixed(1)
                    .replaceAll(RegExp(r'([.]*0)(?!.*\d)'), ""),
                onChanged: (value) {
                  setState(() {
                    sliderValue = value;
                  });
                  widget.question.answer = value.toStringAsFixed(1);
                },
                onChangeEnd: (_) {
                  widget.updater();
                },
              ),
            ),
          ),
        ],
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
