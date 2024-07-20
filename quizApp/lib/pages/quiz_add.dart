import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:quiz_app/api.dart';
import 'package:quiz_app/pages/quiz_edit.dart';

import '../authentication.dart';

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
        body: QuizCreateForm());
  }
}

class QuizCreateForm extends StatelessWidget {
  QuizCreateForm({super.key});

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
                labelText: "Name", labelStyle: TextStyle(color: Colors.white)),
            style: const TextStyle(color: Colors.white),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a name for the quiz";
              }

              return null;
            },
          ),
          ElevatedButton(
              onPressed: () async {
                if (!_formKey.currentState!.validate()) {
                  return;
                }

                final response = await sendApiRequest(
                    "/quiz/new", {"name": nameController.text},
                    authToken: Session().getToken());

                if (response.statusCode != 200) {
                  return;
                }

                log(response.body);
                final body = jsonDecode(response.body);
                final id = int.parse(body["id"]);

                log(context.mounted.toString());
                if (!context.mounted) return;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizEditPage(id: id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                side: const BorderSide(
                  width: 2,
                  color: Colors.white,
                ),
                backgroundColor: Colors.transparent,
              ),
              child: const Text(
                "Create",
                style: TextStyle(
                  color: Colors.white,
                ),
              ))
        ],
      ),
    );
  }
}
