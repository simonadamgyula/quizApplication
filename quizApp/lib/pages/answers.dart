import 'dart:convert';

import 'package:Quim/api.dart';
import 'package:flutter/material.dart';

import '../authentication.dart';
import '../quiz.dart';

class AnswersPage extends StatefulWidget {
  const AnswersPage({
    super.key,
    required this.quiz,
  });

  final Quiz quiz;

  @override
  State<AnswersPage> createState() => _AnswersPageState();
}

class _AnswersPageState extends State<AnswersPage> {
  Map<String, dynamic>? details;

  Future<List<RetrieveAnswer>> getFutureAnswers() async {
    final response = await sendApiRequest(
      "/quiz/answers/get_all",
      {"quiz_id": widget.quiz.id},
      authToken: Session().getToken(),
    );

    if (response.statusCode != 200) {
      throw Exception("Couldn't get answers");
    }

    final body = jsonDecode(response.body);
    details = body["details"];
    return body["answers"]
        .map<RetrieveAnswer>((answer) => RetrieveAnswer.fromJson(answer))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Future<List<RetrieveAnswer>> futureAnswers = getFutureAnswers();

    return Scaffold(
      backgroundColor: const Color(0x00000000),
      appBar: AppBar(
        title: Text(widget.quiz.name),
        backgroundColor: const Color(0xff000000),
      ),
      body: FutureBuilder<List<RetrieveAnswer>>(
        future: futureAnswers,
        builder: (BuildContext context,
            AsyncSnapshot<List<RetrieveAnswer>> snapshot) {
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          List<RetrieveAnswer> answers = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              children:
                  answers.map((answer) => AnswerPreview(answer: answer, details: details![answer.id.toString()],)).toList(),
            ),
          );
        },
      ),
    );
  }
}

class AnswerPreview extends StatelessWidget {
  const AnswerPreview({
    super.key,
    required this.answer,
    required this.details,
  });

  final RetrieveAnswer answer;
  final Map<String, dynamic> details;

  @override
  Widget build(BuildContext context) {
    return Text(answer.answers.toString());
  }
}
