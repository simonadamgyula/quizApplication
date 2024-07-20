import 'package:flutter/material.dart';

import '../quiz.dart';

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

  @override
  void initState() {
    setState(() {
      type = widget.question.type;
    });
    super.initState();
  }

  void typeSelectCallback(int value) {
    widget.question.type = value;
    setState(() {
      type = value;
    });
    Navigator.pop(context);
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
              TypeSelectButton("True or false", callback: typeSelectCallback, icon: Icons.indeterminate_check_box_sharp, value: 0),
              TypeSelectButton("Single choice", callback: typeSelectCallback, icon: Icons.indeterminate_check_box_sharp, value: 1),
              TypeSelectButton("Multiple choice", callback: typeSelectCallback, icon: Icons.indeterminate_check_box_sharp, value: 2)
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
          MaterialButton(
            onPressed: () {
              showTypeSelect();
            },
            child: Row(
              children: [
                Text(
                  widget.question.typeString,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class TypeSelectButton extends StatelessWidget {
  const TypeSelectButton(this.text, {super.key, required this.callback, required this.icon, required this.value});

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