import 'package:Quim/pages/question.dart';
import 'package:flutter/material.dart';

import '../authentication.dart';
import '../quiz.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.quiz});

  final Quiz quiz;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Future<bool> _futureGetQuestions(Quiz quiz) async {
    await quiz.loadQuestions();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final Future<bool> futureLoadQuestions = _futureGetQuestions(widget.quiz);

    final Color color = Color(widget.quiz.color);

    return Scaffold(
      backgroundColor: const Color(0xff000000),
      appBar: AppBar(
        backgroundColor: const Color(0xff000000),
        foregroundColor: Colors.white,
        title: const Text(""),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 40),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(
                      Icons.crop_square_rounded,
                      color: color,
                    ),
                  ),
                ],
              ),
              Text(
                widget.quiz.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.quiz.description ?? "",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                    width: 2,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.transparent,
                  maximumSize: const Size.fromWidth(100),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuestionPage(
                        quiz: widget.quiz,
                        question: widget.quiz.questions[0],
                        answers: Answer(
                            user: Session().getToken()!,
                            length: widget.quiz.questions.length),
                        index: 0,
                      ),
                    ),
                  );
                },
                child: FutureBuilder<bool>(
                  future: futureLoadQuestions,
                  builder: (context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }

                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator(color: Colors.white);
                    }

                    return const Text(
                      "Fill out",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
