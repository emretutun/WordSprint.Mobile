class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final int? dailyWordGoal;
  final String? estimatedLevel;

  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.dailyWordGoal,
    this.estimatedLevel,
  });

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "dailyWordGoal": dailyWordGoal,
        "estimatedLevel": estimatedLevel,
      };
}
