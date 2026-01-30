class AuthResponse {
  final String accessToken;
  final DateTime expiresAtUtc;

  AuthResponse({required this.accessToken, required this.expiresAtUtc});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json["accessToken"] as String,
      expiresAtUtc: DateTime.parse(json["expiresAtUtc"] as String),
    );
  }
}
