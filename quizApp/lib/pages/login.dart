import 'package:flutter/material.dart';
import 'package:quiz_app/authentication.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: const Center(child: LoginForm()),
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

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: [
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
          ),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data')),
              );

              final token = await logIn(usernameController.text, passwordController.text);
              if (token == null) {
                return;
              }

              if (!context.mounted) return;

              Navigator.of(context).pop(token);
            },
            child: const Text("Log in"),
          )
        ]));
  }
}
