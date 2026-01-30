class QuizQuestion {
  final int wordId;
  final int mode;
  final String prompt;
  final List<String>? choices;
  final String expectedLanguage;

  QuizQuestion({
    required this.wordId,
    required this.mode,
    required this.prompt,
    required this.choices,
    required this.expectedLanguage,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      wordId: (json["wordId"] as num).toInt(),
      mode: (json["mode"] as num).toInt(),
      prompt: json["prompt"] as String,
      choices: (json["choices"] as List?)?.map((e) => e.toString()).toList(),
      expectedLanguage: json["expectedLanguage"] as String,
    );
  }
}
