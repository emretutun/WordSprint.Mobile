import 'dart:convert';
import '../../../core/network/api.dart';
import '../../../core/network/api_client.dart';
import '../models/leaderboard_item.dart';

class LeaderboardService {
  final ApiClient _client = ApiClient();

  Future<List<LeaderboardItem>> getTopDays({int limit = 5}) async {
    final uri = Uri.parse("${Api.leaderboardTopDays}?limit=$limit");
    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Leaderboard(days) failed: ${res.statusCode} ${res.body}");
    }

    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => LeaderboardItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<LeaderboardItem>> getTopLearned({int limit = 10}) async {
    final uri = Uri.parse("${Api.leaderboardTopLearned}?limit=$limit");
    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Leaderboard(learned) failed: ${res.statusCode} ${res.body}");
    }

    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => LeaderboardItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
