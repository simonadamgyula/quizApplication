import 'package:flutter/material.dart';
import 'package:quiz_app/authentication.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff181b23),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: const Center(child: RegisterForm()),
      backgroundColor: const Color(0x00000000),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

  bool submitting = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        margin: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: usernameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter a username!";
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
                  return "Please enter a password!";
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
            TextFormField(
              controller: rePasswordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your password again!";
                }
                if (passwordController.text != value) {
                  return "Passwords need to match";
                }

                return null;
              },
              decoration: const InputDecoration(
                labelText: "Repeat password",
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
                  });

                  if (passwordController.text != rePasswordController.text) return;

                  final token = await register(
                      usernameController.text, passwordController.text);
                  if (token == null) {
                    return;
                  }
                  setState(() {
                    submitting = false;
                  });

                  if (!context.mounted) return;

                  Navigator.pop(context, token);
                },
                child: submitting
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
                    : const Text(
                  "Register",
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
