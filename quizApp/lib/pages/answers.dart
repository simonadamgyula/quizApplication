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
  Map<int, List>? details;

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
        .map((answer) => RetrieveAnswer.fromJson(answer))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    Future<List<RetrieveAnswer>> futureAnswers = getFutureAnswers();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.name),
      ),
      body: FutureBuilder<List<RetrieveAnswer>>(
        future: futureAnswers,
        builder: (BuildContext context, AsyncSnapshot<List<RetrieveAnswer>> snapshot) {
          return const SizedBox();
        },
      ),
    );
  }
}

class AnswerPreview extends StatelessWidget {
  const AnswerPreview({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
