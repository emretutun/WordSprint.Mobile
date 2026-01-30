import 'quiz_question.dart';

class StartQuizResponse {
  final List<QuizQuestion> questions;

  StartQuizResponse({required this.questions});

  factory StartQuizResponse.fromJson(Map<String, dynamic> json) {
    final list = (json["questions"] as List? ?? [])
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
    return StartQuizResponse(questions: list);
  }
}
