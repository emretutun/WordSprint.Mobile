import 'dart:convert';
import '../../../core/network/api.dart';
import '../../../core/network/api_client.dart';
import '../models/learned_word_item.dart';

class RepeatService {
  final ApiClient _client = ApiClient();

  Future<List<LearnedWordItem>> getLearnedList() async {
    final uri = Uri.parse(Api.learnedWords);
    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Learned list failed: ${res.statusCode} ${res.body}");
    }

    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => LearnedWordItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
