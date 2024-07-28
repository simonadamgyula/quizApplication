import 'dart:convert';
import 'dart:developer';

import 'package:quim/api.dart';
import 'package:flutter/material.dart';
import 'package:quim/pages/answer.dart';

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
        backgroundColor: const Color(0xff181b23),
        foregroundColor: Colors.white,
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
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: answers
                    .map((answer) => AnswerPreview(
                          answer: answer,
                          details: details![answer.id.toString()],
                          quiz: widget.quiz,
                        ))
                    .toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnswerPreview extends StatefulWidget {
  const AnswerPreview({
    super.key,
    required this.answer,
    required this.details,
    required this.quiz,
  });

  final Quiz quiz;
  final RetrieveAnswer answer;
  final Map<String, dynamic> details;

  @override
  State<AnswerPreview> createState() => _AnswerPreviewState();
}

class _AnswerPreviewState extends State<AnswerPreview> {
  String? username;
  Future<String>? _futureUsername;

  Future<String> getUsername() async {
    final response = await sendApiRequest(
      "/user/get_username",
      {
        "user_id": widget.answer.userId,
      },
      authToken: Session().getToken(),
    );

    if (response.statusCode != 200) {
      log(response.body);
      throw Exception("Couldn't get username");
    }

    final body = jsonDecode(response.body);
    setState(() {
      username = body["username"];
    });
    return body["username"];
  }

  @override
  void initState() {
    _futureUsername = getUsername();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (username != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnswerPage(
                quiz: widget.quiz,
                answer: widget.answer,
                username: username!,
                details: widget.details,
              ),
            ),
          );
        }
      },
      child: Card(
        color: const Color(0xff181b23),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          margin: const EdgeInsets.all(2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FutureBuilder(
                future: _futureUsername,
                builder: (context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasError) {
                    return const Text(
                      "Couldn't load",
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Text(
                      "Loading...",
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  }

                  final String username = snapshot.data!;

                  return Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  );
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${widget.answer.scoreEarned} / ${widget.quiz.maxPoints}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${(widget.answer.scoreEarned / widget.quiz.maxPoints) * 100}%",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
