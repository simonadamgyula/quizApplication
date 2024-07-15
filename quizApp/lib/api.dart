import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const String apiUrl = "http://192.168.1.93:3000";

Future<http.Response> sendApiRequest(String path, Map<String, dynamic> body,
    { String? authToken }) {
  return http.post(
    Uri.parse(apiUrl + path),
    body: jsonEncode(body),
    headers: <String, String>{
      HttpHeaders.authorizationHeader: authToken ?? "Bearer ${authToken ?? ''}",
      HttpHeaders.contentTypeHeader: "application/json"
    }
  );
}
