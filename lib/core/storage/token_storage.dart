import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _keyAccessToken = "access_token";

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: _keyAccessToken);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _keyAccessToken);
  }

  // shared_preferences import etmeyi unutma
static Future<void> saveEmail(String email) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('remembered_email', email);
}

static Future<String?> getSavedEmail() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('remembered_email');
}

static Future<void> clearSavedEmail() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('remembered_email');
}

}
