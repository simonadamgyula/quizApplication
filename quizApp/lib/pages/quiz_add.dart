import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuizAddPage extends StatelessWidget {
  const QuizAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0x00000000),
        appBar: AppBar(
          title: const Text(
            "Create quiz",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xff181b23),
          foregroundColor: Colors.white,
        ),
        body: const QuizCreateForm()
    );
  }
}

class QuizCreateForm extends StatelessWidget {
  const QuizCreateForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
                labelText: "Name",
                labelStyle: TextStyle(color: Colors.white)
            ),
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    )
  }

}