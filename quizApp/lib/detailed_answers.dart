import 'dart:developer';

import 'package:quim/quiz.dart';
import 'package:flutter/material.dart';

import 'style.dart';

class DetailedAnswers extends StatelessWidget {
  const DetailedAnswers({
    super.key,
    required this.details,
    required this.quiz,
  });

  final Map<String, dynamic> details;
  final Quiz quiz;

  Icon statusIcon(bool correct, bool selected) {
    final binary = (correct ? 1 : 0) + (selected ? 2 : 0);

    return [
      const Icon(Icons.abc, color: Colors.transparent),
      // not selected, not correct
      const Icon(Icons.close, color: Colors.red),
      // not selected, correct
      const Icon(Icons.circle_outlined, color: Colors.red),
      // selected, not correct
      const Icon(Icons.check_circle_outline, color: Colors.green)
      // selected, correct
    ][binary];
  }

  Widget questionDetails(Question question, List<dynamic> detail) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              question.question,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ) as Widget
        ] +
            detail[0].asMap().entries.map<Widget>((entry) {
              final option = entry.value;
              final index = entry.key;

              final [correct, selected] = detail[1][index];

              return detailOption(option, index, correct, selected);
            }).toList(),
      ),
    );
  }

  Widget detailOption(String option, int index, bool correct, bool selected) {
    return Card(
      color: colors[index],
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              option,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle,
              ),
              child: statusIcon(correct, selected),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    log(details.toString());

    return Container(
      margin: const EdgeInsets.all(10).add(const EdgeInsets.only(top: 30)),
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: details.entries.map((entry) {
          final id = entry.key;
          final question = quiz.questions
              .where((question) => question.id.toString() == id)
              .first;
          final detail = entry.value;

          return questionDetails(question, detail);
        }).toList(),
      ),
    );
  }
}