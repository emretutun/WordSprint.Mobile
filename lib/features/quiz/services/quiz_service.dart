import 'dart:convert';
import '../../../core/network/api.dart';
import '../../../core/network/api_client.dart';
import '../models/start_quiz_response.dart';
import '../models/submit_quiz_models.dart';

class QuizService {
  final ApiClient _client = ApiClient();

  Future<StartQuizResponse> start({int count = 10, int mode = 1}) async {
    final uri = Uri.parse("${Api.quizStart}?count=$count&mode=$mode");
    final res = await _client.post(uri);

    if (res.statusCode != 200) {
      throw Exception("Quiz start failed: ${res.statusCode} ${res.body}");
    }

    final json = _client.decodeJson(res);
    return StartQuizResponse.fromJson(json);
  }

  Future<SubmitQuizResponse> submit(SubmitQuizRequest request) async {
    final uri = Uri.parse(Api.quizSubmit);
    final res = await _client.post(uri, body: jsonEncode(request.toJson()));

    if (res.statusCode != 200) {
      throw Exception("Quiz submit failed: ${res.statusCode} ${res.body}");
    }

    final json = _client.decodeJson(res);
    return SubmitQuizResponse.fromJson(json);
  }
  Future<StartQuizResponse> startRepeat({int count = 10, int mode = 2}) async {
  final uri = Uri.parse("${Api.repeatStart}?count=$count&mode=$mode");

  // backend repeat start büyük ihtimal POST
  final res = await _client.post(uri, body: jsonEncode({}));

  if (res.statusCode != 200) {
    throw Exception("Repeat start failed: ${res.statusCode} ${res.body}");
  }

  final json = _client.decodeJson(res);
  return StartQuizResponse.fromJson(json);
}

Future<SubmitQuizResponse> submitRepeat(SubmitQuizRequest request) async {
  final uri = Uri.parse(Api.repeatSubmit);
  final res = await _client.post(uri, body: jsonEncode(request.toJson()));

  if (res.statusCode != 200) {
    throw Exception("Repeat submit failed: ${res.statusCode} ${res.body}");
  }

  final json = _client.decodeJson(res);
  return SubmitQuizResponse.fromJson(json);
}

}
