import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/api.dart';
import 'package:quiz_app/pages/login.dart';
import 'package:quiz_app/pages/quiz.dart';
import 'package:quiz_app/pages/quiz_add.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication.dart';
import '../quiz.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _key = GlobalKey<ExpandableFabState>();

  final FocusNode numberNode = FocusNode();
  bool loading = false;
  bool finishedInit = false;

  List<TextEditingController?> controllers = [];
  List<FocusNode?> focuses = [];

  Future<void> loadSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionToken = prefs.getString("token");

    if (sessionToken != null) {
      Session().setToken(sessionToken);
    }
    setState(() {
      finishedInit = true;
    });
  }

  @override
  void initState() {
    for (var i = 0; i < 8; i++) {
      controllers.add(TextEditingController());

      if (i == 0) {
        continue;
      }
      focuses.add(FocusNode());
      if (i == 3) {
        controllers.add(null);
      }
    }
    loadSessionId();
    super.initState();
  }

  Future<Quiz> _futureGetQuiz(String code) async {
    final response = await sendApiRequest(
      "/quiz/get",
      {"code": code},
      authToken: Session().getToken(),
    );

    if (response.statusCode != 200) {
      throw Exception(response.statusCode.toString());
    }

    final body = jsonDecode(response.body);
    return Quiz.fromJson(body);
  }

  void clearCode() {
    for (var controller in controllers) {
      controller?.clear();
    }
  }

  Future<void> _openQuizCodeDialog(BuildContext context) {
    bool pastDash = false;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(20),
          backgroundColor: const Color(0xff181b23),
          children: [
            const Text(
              "Fill out quiz",
              style: TextStyle(color: Colors.white),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: controllers.asMap().entries.map((entry) {
                final int index = entry.key - (pastDash ? 1 : 0);
                final TextEditingController? controller = entry.value;

                if (controller == null) {
                  pastDash = true;
                  return const Text(
                    "-",
                    style: TextStyle(color: Colors.white),
                  );
                }

                FocusNode? current = index == 0 ? null : focuses[index - 1];
                FocusNode? next =
                    index == focuses.length ? null : focuses[index];

                return SingleNumberInput(
                  controller: controller,
                  focus: current,
                  nextFocus: next,
                );
              }).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    List<String> codeList = controllers.map((controller) {
                      return controller?.text ?? "";
                    }).toList();
                    String code = codeList.join();

                    setState(() {
                      loading = true;
                    });

                    _futureGetQuiz(code).then((quiz) {
                      if (!loading) return;

                      setState(() {
                        loading = false;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QuizPage(
                                  quiz: quiz,
                                )),
                      );
                    }).catchError((error) {
                      if (!loading || !context.mounted) return;

                      setState(() {
                        loading = false;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.toString())));
                    });
                  },
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Enter"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      loading = false;
                    });
                    clearCode();
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff000000),
      appBar: AppBar(
        backgroundColor: const Color(0xff181b23),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: finishedInit
          ? ChangeNotifierProvider<Session>(
              create: (context) => Session(),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Consumer<Session>(
                      builder: (context, session, child) {
                        if (session.getToken() == null) {
                          return LoginButton(session: session);
                        }

                        return Text(session.getToken()!);
                      },
                    ),
                  ],
                ),
              ),
            )
          : const CircularProgressIndicator(
              color: Colors.white,
            ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        type: ExpandableFabType.up,
        childrenAnimation: ExpandableFabAnimation.none,
        distance: 70,
        childrenOffset: const Offset(-3, 10),
        overlayStyle: ExpandableFabOverlayStyle(
          color: Colors.white.withOpacity(0.1),
        ),
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          child: const Icon(Icons.add),
          fabSize: ExpandableFabSize.regular,
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xff6dd35e),
          shape: const CircleBorder(),
        ),
        closeButtonBuilder: DefaultFloatingActionButtonBuilder(
          child: const Icon(Icons.close),
          fabSize: ExpandableFabSize.small,
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
        ),
        children: [
          Row(
            children: [
              const Text(
                "Create",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 10),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  if (Session().getToken() == null) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QuizAddPage(),
                    ),
                  );
                },
                backgroundColor: const Color(0xff6dd35e),
                foregroundColor: Colors.white,
                child: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                "Fill out",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(width: 10),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: () {
                  final state = _key.currentState;
                  if (state != null) {
                    state.toggle();
                  }
                  _openQuizCodeDialog(context);
                },
                backgroundColor: const Color(0xff2f91e7),
                foregroundColor: Colors.white,
                child: const Icon(Icons.checklist),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class SingleNumberInput extends StatefulWidget {
  const SingleNumberInput(
      {super.key, this.focus, this.nextFocus, required this.controller});

  final FocusNode? focus;
  final FocusNode? nextFocus;
  final TextEditingController controller;

  @override
  State<SingleNumberInput> createState() => _SingleNumberInputState();
}

class _SingleNumberInputState extends State<SingleNumberInput> {
  @override
  void initState() {
    widget.controller.addListener(() {
      if (widget.nextFocus == null) {
        widget.focus?.unfocus();
        return;
      }
      widget.nextFocus!.requestFocus();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 40,
      child: TextField(
        focusNode: widget.focus,
        controller: widget.controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          counterText: "",
          contentPadding: EdgeInsets.all(2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: CupertinoColors.systemGrey4),
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          hintText: "0",
          hintStyle: TextStyle(color: Colors.white),
        ),
        cursorWidth: 0,
        maxLength: 1,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  const LoginButton({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final token = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );

        if (!context.mounted) return;

        session.setToken(token);
      },
      icon: const Icon(Icons.login),
    );
  }
}
