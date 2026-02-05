class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final int? dailyWordGoal;
  final int? level; // 0..5

  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.dailyWordGoal,
    this.level,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (firstName != null) data["firstName"] = firstName;
    if (lastName != null) data["lastName"] = lastName;
    if (dailyWordGoal != null) data["dailyWordGoal"] = dailyWordGoal;
    if (level != null) data["level"] = level;

    return data;
  }
}
