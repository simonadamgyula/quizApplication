import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:quim/pages/quiz_edit.dart';
import 'package:flutter/material.dart';

import '../api.dart';
import '../authentication.dart';
import '../style.dart';

class QuizAddPage extends StatelessWidget {
  const QuizAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            "Create quiz",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
        ),
        body: const QuizCreateForm());
  }
}

class QuizCreateForm extends StatefulWidget {
  const QuizCreateForm({super.key});

  @override
  State<QuizCreateForm> createState() => _QuizCreateFormState();
}

class _QuizCreateFormState extends State<QuizCreateForm> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  bool creating = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: (Colors.grey).withOpacity(0.2),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a name for the quiz";
                }

                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: descriptionController,
              maxLines: null,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                labelText: "Description",
                labelStyle: const TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: (Colors.grey).withOpacity(0.2),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }

                  final random = math.Random();
                  Color currentColor = colors[random.nextInt(colors.length)];

                  final response = await sendApiRequest(
                      "/quiz/new",
                      {
                        "name": nameController.text,
                        "description": descriptionController.text,
                        "color": currentColor.value,
                      },
                      authToken: Session().getToken());

                  if (response.statusCode != 200) {
                    return;
                  }

                  log(response.body);
                  final body = jsonDecode(utf8.decode(response.bodyBytes));
                  final id = body["id"];

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
                child: creating
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        "Create",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
