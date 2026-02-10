import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:wordsprint/features/profile/models/change_password_request.dart';
import '../../../core/network/api.dart';
import '../../../core/storage/token_storage.dart';
import '../models/login_request.dart';
import '../models/auth_response.dart';
import '../models/register_request.dart';
import '../models/forgot_password_request.dart';
import '../models/reset_password_request.dart';
import '../models/forgot_password_code_request.dart';
import '../models/verify_reset_code_request.dart';
import '../models/reset_password_with_code_request.dart';


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

Future<void> register(RegisterRequest request) async {
  final uri = Uri.parse(Api.register);

  final res = await http.post(
    uri,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(request.toJson()),
  );

  if (res.statusCode != 200) {
    throw Exception("Register failed: ${res.statusCode} ${res.body}");
  }
}
Future<void> forgotPassword(ForgotPasswordRequest request) async {
  final uri = Uri.parse(Api.forgotPassword);

  final res = await http.post(
    uri,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(request.toJson()),
  );

  if (res.statusCode != 200) {
    throw Exception("Forgot password failed: ${res.statusCode} ${res.body}");
  }
}

Future<void> resetPassword(ResetPasswordRequest request) async {
  final uri = Uri.parse(Api.resetPassword);

  final res = await http.post(
    uri,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(request.toJson()),
  );

  if (res.statusCode != 200) {
    throw Exception("Reset password failed: ${res.statusCode} ${res.body}");
  }
}

Future<void> changePassword(ChangePasswordRequest request) async {
  final token = await TokenStorage.getToken();
  if (token == null || token.isEmpty) {
    throw Exception("No token. Please login again.");
  }

  final uri = Uri.parse(Api.changePassword);

  final res = await http.post(
    uri,
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
    body: jsonEncode(request.toJson()),
  );

  if (res.statusCode != 200) {
    throw Exception("Change password failed: ${res.statusCode} ${res.body}");
  }
}

Future<void> forgotPasswordCode(ForgotPasswordCodeRequest request) async {
  final uri = Uri.parse(Api.forgotPasswordCode);

  final res = await http.post(
    uri,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(request.toJson()),
  );

  if (res.statusCode != 200) {
    throw Exception("Forgot password code failed: ${res.statusCode} ${res.body}");
  }
}

Future<void> verifyResetCode(VerifyResetCodeRequest request) async {
  final uri = Uri.parse(Api.verifyResetCode);

  final res = await http.post(
    uri,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(request.toJson()),
  );

  if (res.statusCode != 200) {
    throw Exception("Verify reset code failed: ${res.statusCode} ${res.body}");
  }
}

Future<void> resetPasswordWithCode(ResetPasswordWithCodeRequest request) async {
  final uri = Uri.parse(Api.resetPasswordWithCode);

  final res = await http.post(
    uri,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(request.toJson()),
  );

  if (res.statusCode != 200) {
    throw Exception("Reset password with code failed: ${res.statusCode} ${res.body}");
  }
}



}
