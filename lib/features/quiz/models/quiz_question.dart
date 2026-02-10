class QuizQuestion {
  final int wordId;
  final int level;
  final String prompt;
  final String expectedLanguage;
  final List<String>? choices;
  final int mode;

  QuizQuestion({
    required this.wordId,
    required this.level,
    required this.prompt,
    required this.expectedLanguage,
    this.choices,
    required this.mode,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
     
      wordId: (json['wordId'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 0,
      mode: (json['mode'] as num?)?.toInt() ?? 0,
      
      
      prompt: (json['prompt'] ?? "") as String,
      expectedLanguage: (json['expectedLanguage'] ?? "") as String,
      
      
      choices: json['choices'] == null
          ? null
          : List<String>.from(json['choices']),
    );
  }
}