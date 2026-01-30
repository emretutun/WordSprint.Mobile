import 'dart:convert';
import '../../../core/network/api.dart';
import '../../../core/network/api_client.dart';
import '../models/learning_word_item.dart';

class LearningService {
  final ApiClient _client = ApiClient();

  Future<void> assignRandom({int count = 10}) async {
    final uri = Uri.parse("${Api.assignWords}?count=$count");
    final res = await _client.post(uri, body: jsonEncode({}));

    // backend bazen 200/204 dönebilir, biz esnek olalım
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception("Assign failed: ${res.statusCode} ${res.body}");
    }
  }

  Future<List<LearningWordItem>> getLearningList() async {
    final uri = Uri.parse(Api.learningWords);
    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Learning list failed: ${res.statusCode} ${res.body}");
    }

    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => LearningWordItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
