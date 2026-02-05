class QuizQuestion {
  final int wordId;
  final int level; 
  final String prompt;
  final String expectedLanguage;
  final List<String>? choices;

  QuizQuestion({
    required this.wordId,
    required this.level,
    required this.prompt,
    required this.expectedLanguage,
    this.choices,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      wordId: json['wordId'],
      level: json['level'], // 👈 EKLENDİ
      prompt: json['prompt'],
      expectedLanguage: json['expectedLanguage'],
      choices: json['choices'] == null
          ? null
          : List<String>.from(json['choices']),
    );
  }
}
