class QuizMode {
  static const int mixed = 0;

  static const int trToEnTyping = 1;
  static const int enToTrTyping = 2;
  static const int trToEnMultipleChoice = 3;
  static const int enToTrMultipleChoice = 4;

  static String label(int mode) {
    switch (mode) {
      case mixed:
        return "Karışık (Random)";
      case trToEnTyping:
        return "TR → EN (Yazma)";
      case enToTrTyping:
        return "EN → TR (Yazma)";
      case trToEnMultipleChoice:
        return "TR → EN (Çoktan Seçmeli)";
      case enToTrMultipleChoice:
        return "EN → TR (Çoktan Seçmeli)";
      default:
        return "Karışık (Random)";
    }
  }
}
