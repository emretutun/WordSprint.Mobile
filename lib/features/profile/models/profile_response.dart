class ProfileResponse {
  final String userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final int dailyWordGoal;
  final int level; // 0..5
  final String photoUrl;

  ProfileResponse({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dailyWordGoal,
    required this.level,
    required this.photoUrl,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      userId: json["userId"] as String,
      email: json["email"] as String,
      firstName: json["firstName"] as String?,
      lastName: json["lastName"] as String?,
      dailyWordGoal: (json["dailyWordGoal"] as num).toInt(),
      level: (json["level"] as num?)?.toInt() ?? 0,
      photoUrl: json["photoUrl"] as String,
    );
  }
}
