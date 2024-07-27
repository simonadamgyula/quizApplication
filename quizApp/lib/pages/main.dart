import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/api.dart';
import 'package:quiz_app/pages/login.dart';
import 'package:quiz_app/pages/quiz.dart';
import 'package:quiz_app/pages/quiz_add.dart';
import 'package:quiz_app/pages/quiz_edit.dart';
import 'package:quiz_app/pages/register.dart';
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

  void updateCallback() {
    setState(() {});
  }

  Future<void> _openQuizCodeDialog(BuildContext context) {
    bool pastDash = false;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(20),
          backgroundColor: const Color(0xff181b23),
          title: const Text(
            "Fill out quiz",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: controllers.asMap().entries.map((entry) {
                final int index = entry.key - (pastDash ? 1 : 0);
                final TextEditingController? controller = entry.value;

                if (controller == null) {
                  pastDash = true;
                  return const Padding(
                    padding: EdgeInsets.all(1),
                    child: Icon(
                      Icons.remove,
                      color: Colors.white,
                      size: 10,
                    ),
                  );
                }

                FocusNode? current = index == 0 ? null : focuses[index - 1];
                FocusNode? next =
                    index == focuses.length ? null : focuses[index];

                return Padding(
                  padding: const EdgeInsets.all(1),
                  child: SingleNumberInput(
                    controller: controller,
                    focus: current,
                    nextFocus: next,
                  ),
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
    return ChangeNotifierProvider<Session>(
      create: (context) => Session(),
      child: Scaffold(
        backgroundColor: const Color(0xff000000),
        appBar: AppBar(
          backgroundColor: const Color(0xff181b23),
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            Consumer<Session>(
              builder: (context, session, child) {
                if (session.getToken() != null) {
                  return PopupMenuButton(
                    icon: const Icon(Icons.account_circle),
                    iconColor: Colors.white,
                    color: const Color(0xff1d212b),
                    itemBuilder: (context) => <PopupMenuEntry>[
                      PopupMenuItem(
                        child: const Text(
                          "Log out",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        onTap: () {
                          Session().logOut().catchError((error) {
                            log(error.toString());
                            Fluttertoast.showToast(
                              msg: error.toString(),
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          });
                        },
                      ),
                    ],
                  );
                }

                return PopupMenuButton(
                  icon: const Icon(Icons.login),
                  iconColor: Colors.white,
                  color: const Color(0xff1d212b),
                  itemBuilder: (context) => <PopupMenuEntry>[
                    PopupMenuItem(
                      child: const Text(
                        "Log in",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () async {
                        final token = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const LoginPage(),
                          ),
                        );

                        if (!context.mounted) return;

                        session.setToken(token);
                      },
                    ),
                    PopupMenuItem(
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () async {
                        final token = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const RegisterPage(),
                          ),
                        );

                        if (!context.mounted) return;

                        session.setToken(token);
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: finishedInit
            ? Consumer<Session>(
                builder: (context, session, child) {
                  if (session.getToken() == null) {
                    return const Center(
                      child: Text(
                        "You are not logged in",
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return QuizList(
                    session: session,
                    updateCallback: updateCallback,
                  );
                },
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
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
      ),
    );
  }
}

class QuizList extends StatelessWidget {
  const QuizList({
    super.key,
    required this.session,
    required this.updateCallback,
  });

  final Session session;
  final void Function() updateCallback;

  Future<List<Quiz>> getOwnedQuizzes() async {
    final response = await sendApiRequest(
      "/quiz/get_all",
      {},
      authToken: session.getToken(),
    );

    if (response.statusCode != 200) {
      throw Exception("Unable to load your quizzes.");
    }

    final body = jsonDecode(response.body) as List;
    return body.map((quiz) => Quiz.fromJson(quiz)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final futureQuizzes = getOwnedQuizzes();

    return FutureBuilder<List<Quiz>>(
      future: futureQuizzes,
      builder: (context, AsyncSnapshot<List<Quiz>> snapshot) {
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

        final List<Quiz> quizzes = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: quizzes.isEmpty
                  ? [
                      const Center(
                        child: Text("You have no quizzes."),
                      )
                    ]
                  : quizzes
                      .map((quiz) => QuizPreview(
                            quiz: quiz,
                            updateCallback: updateCallback,
                          ))
                      .toList(),
            ),
          ),
        );
      },
    );
  }
}

class QuizPreview extends StatelessWidget {
  const QuizPreview({
    super.key,
    required this.quiz,
    required this.updateCallback,
  });

  final Quiz quiz;
  final void Function() updateCallback;

  @override
  Widget build(BuildContext context) {
    final currentColor = Color(quiz.color);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuizEditPage(id: quiz.id),
            settings: const RouteSettings(name: "quiz_edit"),
          ),
        ).then((_) => updateCallback());
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xff181b23),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: currentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(
                Icons.crop_square_rounded,
                color: currentColor,
              ),
            ),
            Text(
              quiz.name,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
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
      width: 25,
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
