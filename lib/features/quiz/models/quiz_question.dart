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
      // (json['alan'] as num?)?.toInt() ?? 0 yapısı hem int hem double gelen sayıları güvenle int'e çevirir.
      wordId: (json['wordId'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 0,
      mode: (json['mode'] as num?)?.toInt() ?? 0,
      
      // String alanlar için null kontrolü (?? "") ekleyerek "Null is not a subtype of String" hatasını önlüyoruz.
      prompt: (json['prompt'] ?? "") as String,
      expectedLanguage: (json['expectedLanguage'] ?? "") as String,
      
      // Choices zaten nullable (?) olduğu için null check yeterli.
      choices: json['choices'] == null
          ? null
          : List<String>.from(json['choices']),
    );
  }
}