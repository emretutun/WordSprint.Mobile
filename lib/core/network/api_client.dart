import 'dart:convert';
import 'package:http/http.dart' as http;

import '../storage/token_storage.dart';

class ApiClient {
  Future<http.Response> get(Uri uri) async {
    final headers = await _headers();
    return http.get(uri, headers: headers);
  }

  Future<http.Response> post(Uri uri, {Object? body}) async {
    final headers = await _headers();
    return http.post(uri, headers: headers, body: body);
  }

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getToken();
    final headers = <String, String>{
      "Content-Type": "application/json",
    };

    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  Map<String, dynamic> decodeJson(http.Response res) {
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
