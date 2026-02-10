class SubmitAnswer {
  final int wordId;
  final String answer;
  final int mode;

  SubmitAnswer({
    required this.wordId, 
    required this.answer, 
    required this.mode 
  });

  Map<String, dynamic> toJson() => {
        "wordId": wordId,
        "answer": answer,
        "mode": mode, 
      };
}

class SubmitQuizRequest {
  final int mode;
  final List<SubmitAnswer> answers;

  SubmitQuizRequest({required this.mode, required this.answers});

  Map<String, dynamic> toJson() => {
        "mode": mode,
        "answers": answers.map((a) => a.toJson()).toList(),
      };
}

class QuizResultItem {
  final int wordId;
  final bool isCorrect;

  final String prompt;
  final String userAnswer;
  final String correctAnswer;
  final int level;

  QuizResultItem({
    required this.wordId,
    required this.isCorrect,
    required this.prompt,
    required this.userAnswer,
    required this.correctAnswer,
    required this.level,
  });

  factory QuizResultItem.fromJson(Map<String, dynamic> json) {
    return QuizResultItem(
      wordId: (json["wordId"] as num).toInt(),
      isCorrect: json["isCorrect"] as bool,
      prompt: (json["prompt"] ?? "") as String,
      userAnswer: (json["userAnswer"] ?? "") as String,
      correctAnswer: (json["correctAnswer"] ?? "") as String,
      level: (json["level"] as num).toInt(),
    );
  }
}


class SubmitQuizResponse {
  final int total;
  final int correct;
  final int wrong;
  final double successRate;
  final bool passed;
  final List<QuizResultItem> items;

  SubmitQuizResponse({
    required this.total,
    required this.correct,
    required this.wrong,
    required this.successRate,
    required this.passed,
    required this.items,
  });

  factory SubmitQuizResponse.fromJson(Map<String, dynamic> json) {
    final items = (json["items"] as List? ?? [])
        .map((e) => QuizResultItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return SubmitQuizResponse(
      total: (json["total"] as num).toInt(),
      correct: (json["correct"] as num).toInt(),
      wrong: (json["wrong"] as num).toInt(),
      successRate: (json["successRate"] as num).toDouble(),
      passed: json["passed"] as bool,
      items: items,
    );
  }
}
