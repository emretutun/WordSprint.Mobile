class QuizMode {
  static const int trToEnTyping = 1;
  static const int enToTrTyping = 2;
  static const int trToEnMultipleChoice = 3;
  static const int enToTrMultipleChoice = 4;

  static String label(int mode) {
    switch (mode) {
      case trToEnTyping:
        return "TR → EN (Typing)";
      case enToTrTyping:
        return "EN → TR (Typing)";
      case trToEnMultipleChoice:
        return "TR → EN (Multiple Choice)";
      case enToTrMultipleChoice:
        return "EN → TR (Multiple Choice)";
      default:
        return "Unknown";
    }
  }
}
