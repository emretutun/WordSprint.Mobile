import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';



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
  Future<http.Response> put(Uri uri, {Object? body}) async {
  final headers = await _headers();
  return http.put(uri, headers: headers, body: body);
}
Future<http.StreamedResponse> multipartUpload(
  Uri uri, {
  required File file,
  String fieldName = "File",
}) async {
  final token = await TokenStorage.getToken();

  final request = http.MultipartRequest("POST", uri);

  if (token != null && token.isNotEmpty) {
    request.headers["Authorization"] = "Bearer $token";
  }

  request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

  return request.send();
}


}
