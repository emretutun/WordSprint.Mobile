class Api {
  // LOCAL
  static const String baseUrl = "https://1a24c99c94af.ngrok-free.app/api";
  // Android emulator için:
  // localhost = 10.0.2.2

  // Eğer gerçek cihazda test edersen:
  // static const String baseUrl = "https://192.168.1.XX:7022/api";

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
