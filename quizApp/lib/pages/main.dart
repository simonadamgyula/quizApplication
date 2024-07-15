import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/pages/login.dart';

import '../authentication.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff000000),
      appBar: AppBar(
        backgroundColor: const Color(0xff181b23),
        title: Text(
          title,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
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
