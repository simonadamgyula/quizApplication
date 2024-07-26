import 'package:flutter/material.dart';
import 'package:quiz_app/authentication.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff181b23),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: const Center(child: LoginForm()),
      backgroundColor: const Color(0x00000000),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool submitting = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            error != null
                ? Text(
                    error!,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  )
                : const SizedBox(),
            TextFormField(
              controller: usernameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter the username!";
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: "Username",
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            TextFormField(
              controller: passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter the password!";
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                    width: 2,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.transparent,
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  setState(() {
                    submitting = true;
                    error = null;
                  });

                  final token = await logIn(
                          usernameController.text, passwordController.text)
                      .catchError((error) {
                    setState(() {
                      error = error.toString();
                    });
                    return null;
                  });

                  setState(() {
                    submitting = false;
                  });

                  if (token == null) {
                    return;
                  }

                  if (!context.mounted) return;

                  Navigator.pop(context, token);
                },
                child: submitting
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text(
                        "Log in",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
