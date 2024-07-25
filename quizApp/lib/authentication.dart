import "dart:convert";
import "dart:developer";

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

  void notify() {
    notifyListeners();
  }

  Future<void> logOut() async {
    final response = await sendApiRequest(
      "/logout",
      {},
      authToken: getToken(),
    );
    log(response.statusCode.toString());

    if (response.statusCode != 200) {
      throw Exception("Could not log out");
    }

    session.remove("token");
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("token");

    notifyListeners();
  }
}

Future<String?> logIn(String username, String password) async {
  final response = await sendApiRequest(
      "/login", {"username": username, "password": password});

  if (response.statusCode != 200) {
    return null;
  }

  final body = jsonDecode(response.body);
  return body["token"];
}

Future<String?> register(String username, String password) async {
  final response = await sendApiRequest(
    "/register",
    {
      "username": username,
      "password": password,
    },
  );

  if (response.statusCode == 200) {
    return await logIn(username, password);
  }

  throw Exception(response.body);
}
