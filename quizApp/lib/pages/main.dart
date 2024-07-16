import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/pages/login.dart';

import '../authentication.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _key = GlobalKey<ExpandableFabState>();

  final FocusNode numberNode = FocusNode();

  List<TextEditingController> controllers = [];
  List<FocusNode> focuses = [];

  @override
  void initState() {
    for (var _ = 0; _ < 2; _++) {
      controllers.add(TextEditingController());
      focuses.add(FocusNode());
    }
    super.initState();
  }

  Future<void> _openQuizCodeDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          children: [
            const Text("Fill out quiz"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: controllers.asMap().entries
                  .map(
                      (entry) {
                        int index = entry.key;
                        TextEditingController controller = entry.value;

                        return SingleNumberInput(controller: controller);
                      })
                  .toList(),
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
      body: ChangeNotifierProvider<Session>(
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
              )
            ],
          ),
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
          const Row(
            children: [
              Text(
                "Create",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 10),
              FloatingActionButton.small(
                heroTag: null,
                onPressed: null,
                backgroundColor: Color(0xff6dd35e),
                foregroundColor: Colors.white,
                child: Icon(Icons.add_circle_outline),
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 50,
      child: TextField(
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          widget.nextFocus?.requestFocus();
        },
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
