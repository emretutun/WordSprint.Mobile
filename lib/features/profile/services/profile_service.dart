import '../../../core/network/api.dart';
import '../../../core/network/api_client.dart';
import '../models/profile_response.dart';
import '../models/profile_stats_response.dart';
import 'dart:convert';
import '../models/update_profile_request.dart';
import 'dart:io';




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

Future<void> updateProfile(UpdateProfileRequest request) async {
  final uri = Uri.parse(Api.profile);

  final res = await _client.put(
    uri,
    body: jsonEncode(request.toJson()),
  );

  // backend NoContent dönüyor olabilir
  if (res.statusCode != 204 && res.statusCode != 200) {
    throw Exception("Update failed: ${res.statusCode} ${res.body}");
  }
  
}

Future<void> uploadPhoto(File file) async {
  final uri = Uri.parse(Api.uploadPhoto);

  final res = await _client.multipartUpload(
    uri,
    file: file,
    fieldName: "File",
  );

  final body = await res.stream.bytesToString();

  if (res.statusCode != 200) {
    throw Exception("Photo upload failed: ${res.statusCode} $body");
  }

}



}
