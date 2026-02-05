class LearnedWordItem {
  final int userWordId;
  final int wordId;
  final String english;
  final String turkish;
  final int level;

  LearnedWordItem({
    required this.userWordId,
    required this.wordId,
    required this.english,
    required this.turkish,
    required this.level,
  });

  factory LearnedWordItem.fromJson(Map<String, dynamic> json) {
    return LearnedWordItem(
      userWordId: (json["userWordId"] as num).toInt(),
      wordId: (json["wordId"] as num).toInt(),
      english: json["english"] as String,
      turkish: json["turkish"] as String,
      level: (json["level"] as num?)?.toInt() ?? 0,

    );
  }
}
