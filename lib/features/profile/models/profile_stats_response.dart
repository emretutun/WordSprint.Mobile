class ProfileStatsResponse {
  final int totalLearned;
  final int totalLearning;
  final int totalCorrect;
  final int totalWrong;
  final double successRate;
  final int todayLearned;

  ProfileStatsResponse({
    required this.totalLearned,
    required this.totalLearning,
    required this.totalCorrect,
    required this.totalWrong,
    required this.successRate,
    required this.todayLearned,
  });

  factory ProfileStatsResponse.fromJson(Map<String, dynamic> json) {
    return ProfileStatsResponse(
      totalLearned: (json["totalLearned"] as num).toInt(),
      totalLearning: (json["totalLearning"] as num).toInt(),
      totalCorrect: (json["totalCorrect"] as num).toInt(),
      totalWrong: (json["totalWrong"] as num).toInt(),
      successRate: (json["successRate"] as num).toDouble(),
      todayLearned: (json["todayLearned"] as num).toInt(),
    );
  }
}
