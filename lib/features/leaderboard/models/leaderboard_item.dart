class LeaderboardItem {
  final String userId;
  final String? name;
  final String? email;

  final int? daysLearning;
  final int? learnedCount;

  LeaderboardItem({
    required this.userId,
    required this.name,
    required this.email,
    this.daysLearning,
    this.learnedCount,
  });

  factory LeaderboardItem.fromJson(Map<String, dynamic> json) {
    return LeaderboardItem(
      userId: (json["userId"] ?? "") as String,
      name: json["name"] as String?,
      email: json["email"] as String?,
      daysLearning: (json["daysLearning"] as num?)?.toInt(),
      learnedCount: (json["learnedCount"] as num?)?.toInt(),
    );
  }
}
