import "dart:convert";

import "package:flutter/cupertino.dart";
import "package:quiz_app/api.dart";
import "package:session_storage/session_storage.dart";
import "package:shared_preferences/shared_preferences.dart";

class Session extends ChangeNotifier {
  final session = SessionStorage();

  void setToken(String token) {
    session["token"] = token;
    notifyListeners();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString("token", token);
    });
  }

  String? getToken() {
    return session["token"];
  }
}

Future<String?> logIn(String username, String password) async {
  final response = await sendApiRequest("/login", {"username": username, "password": password});

  if (response.statusCode != 200) {
    return null;
  }

  final body = jsonDecode(response.body);
  return body["token"];
}