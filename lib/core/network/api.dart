class Api {
  
  // LOCAL
  static const String _domain = "https://16f6-46-2-170-136.ngrok-free.app";
  static const String baseUrl = "$_domain/api";

  // AUTH
  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";
  static const String confirmEmail = "$baseUrl/auth/confirm-email";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";
  static const String changePassword = "$baseUrl/auth/change-password";

  // PROFILE
  static const String profile = "$baseUrl/profile";
  static const String profileStats = "$baseUrl/profile/stats";
  static const String uploadPhoto = "$baseUrl/profile/photo";

  // WORDS
  static const String assignWords = "$baseUrl/userwords/assign-random";
  static const String learningWords = "$baseUrl/userwords/learning";
  static const String learnedWords = "$baseUrl/userwords/learned";

  // QUIZ
  static const String quizStart = "$baseUrl/quiz/start";
  static const String quizSubmit = "$baseUrl/quiz/submit";
  static const String repeatStart = "$baseUrl/quiz/repeat/start";
  static const String repeatSubmit = "$baseUrl/quiz/repeat/submit";
}
