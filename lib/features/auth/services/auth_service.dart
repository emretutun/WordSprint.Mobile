import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api.dart';
import '../../../core/storage/token_storage.dart';
import '../models/login_request.dart';
import '../models/auth_response.dart';

class AuthService {
  Future<AuthResponse> login(LoginRequest request) async {
    final uri = Uri.parse(Api.login);

    final res = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(request.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception("Login failed: ${res.statusCode} ${res.body}");
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final auth = AuthResponse.fromJson(json);

    await TokenStorage.saveToken(auth.accessToken);
    return auth;
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();
  }
}
