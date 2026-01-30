class LearningWordItem {
  final int userWordId;
  final int wordId;
  final String english;
  final String turkish;

  LearningWordItem({
    required this.userWordId,
    required this.wordId,
    required this.english,
    required this.turkish,
  });

  factory LearningWordItem.fromJson(Map<String, dynamic> json) {
    return LearningWordItem(
      userWordId: (json["userWordId"] as num).toInt(),
      wordId: (json["wordId"] as num).toInt(),
      english: json["english"] as String,
      turkish: json["turkish"] as String,
    );
  }
}
