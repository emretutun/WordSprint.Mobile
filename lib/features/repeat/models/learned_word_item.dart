class LearnedWordItem {
  final int userWordId;
  final int wordId;
  final String english;
  final String turkish;

  LearnedWordItem({
    required this.userWordId,
    required this.wordId,
    required this.english,
    required this.turkish,
  });

  factory LearnedWordItem.fromJson(Map<String, dynamic> json) {
    return LearnedWordItem(
      userWordId: (json["userWordId"] as num).toInt(),
      wordId: (json["wordId"] as num).toInt(),
      english: json["english"] as String,
      turkish: json["turkish"] as String,
    );
  }
}
