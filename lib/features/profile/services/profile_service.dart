import '../../../core/network/api.dart';
import '../../../core/network/api_client.dart';
import '../models/profile_response.dart';
import '../models/profile_stats_response.dart';


class ProfileService {
  final ApiClient _client = ApiClient();

  Future<ProfileResponse> getProfile() async {
    final uri = Uri.parse(Api.profile);
    final res = await _client.get(uri);

    if (res.statusCode != 200) {
      throw Exception("Profile failed: ${res.statusCode} ${res.body}");
    }

    final json = _client.decodeJson(res);
    return ProfileResponse.fromJson(json);
  }

  Future<ProfileStatsResponse> getStats() async {
  final uri = Uri.parse(Api.profileStats);
  final res = await _client.get(uri);

  if (res.statusCode != 200) {
    throw Exception("Stats failed: ${res.statusCode} ${res.body}");
  }

  final json = _client.decodeJson(res);
  return ProfileStatsResponse.fromJson(json);
}


}
