class ProfileResponse {
  final String userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final int dailyWordGoal;
  final String? estimatedLevel;
  final String photoUrl;

  ProfileResponse({
    required this.userId,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dailyWordGoal,
    required this.estimatedLevel,
    required this.photoUrl,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      userId: json["userId"] as String,
      email: json["email"] as String,
      firstName: json["firstName"] as String?,
      lastName: json["lastName"] as String?,
      dailyWordGoal: (json["dailyWordGoal"] as num).toInt(),
      estimatedLevel: json["estimatedLevel"] as String?,
      photoUrl: json["photoUrl"] as String,
    );
  }
}
