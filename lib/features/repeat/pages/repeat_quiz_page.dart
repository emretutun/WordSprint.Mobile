import 'package:flutter/material.dart';
import '../../quiz/models/quiz_mode.dart';
import '../../quiz/models/quiz_question.dart';
import '../../quiz/models/submit_quiz_models.dart';
import '../../quiz/services/quiz_service.dart';

class RepeatQuizPage extends StatefulWidget {
  const RepeatQuizPage({super.key});

  @override
  State<RepeatQuizPage> createState() => _RepeatQuizPageState();
}

class _RepeatQuizPageState extends State<RepeatQuizPage> {
  final _service = QuizService();
  bool _loading = true;
  String? _error;
  List<QuizQuestion> _questions = [];
  int _index = 0;
  final _answerCtrl = TextEditingController();
  final List<SubmitAnswer> _answers = [];
  
  // Mixed (Karışık) Mod artık default
  int _mode = QuizMode.mixed;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    setState(() {
      _loading = true;
      _error = null;
      _index = 0;
      _answers.clear();
      _answerCtrl.clear();
    });
    try {
      final res = await _service.startRepeat(count: 10, mode: _mode);
      setState(() => _questions = res.questions);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _handleAnswer(String answer) {
    final q = _questions[_index];
    
    // Yazma modunda boş cevap kontrolü
    bool isTypingMode = q.choices == null || q.choices!.isEmpty;
    if (isTypingMode && answer.trim().isEmpty) return;

    // Cevabı ekle ve o sorunun kendi modunu gönder
    _answers.add(SubmitAnswer(
      wordId: q.wordId, 
      answer: answer.trim(),
      mode: q.mode // Karışık modda her soru kendi modunu taşır
    ));
    
    _answerCtrl.clear();

    if (_index < _questions.length - 1) {
      setState(() => _index++);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    setState(() { _loading = true; });
    try {
      final result = await _service.submitRepeat(
        SubmitQuizRequest(mode: _mode, answers: _answers),
      );
      if (!mounted) return;
      _showResultDialog(result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showResultDialog(dynamic result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Center(child: Text("Hafıza Tazelendi! 🏁")),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildResultRow("Doğru", "${result.correct}", Colors.green),
                _buildResultRow("Yanlış", "${result.wrong}", Colors.red),
                const Divider(height: 28),
                Text(
                  "%${result.successRate.toStringAsFixed(0)} Başarı Oranı",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 18),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Detaylar", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                
                ...(result.items as List).map((it) {
                  final bool ok = it.isCorrect ?? false;
                  final String prompt = it.prompt ?? "Kelime";
                  final String userAns = it.userAnswer ?? "";
                  final String correctAns = it.correctAnswer ?? "";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: ok ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(ok ? Icons.check_circle : Icons.cancel, color: ok ? Colors.green : Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(prompt, style: const TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("Sen: ${userAns.isEmpty ? "(boş)" : userAns}", 
                             style: TextStyle(color: ok ? Colors.green.shade700 : Colors.red.shade700, fontSize: 13)),
                        if (!ok) Text("Doğru: $correctAns", 
                             style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              child: const Text("TAMAM"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.orange)));
    if (_error != null || _questions.isEmpty) return _buildErrorOrEmpty();

    final q = _questions[_index];
    
    // Sorunun kendi içinde choices varsa Çoktan Seçmeli gösterir
    final bool isMultipleChoice = (q.choices != null && q.choices!.isNotEmpty);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _buildProgressHeader(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildModeSelector(),
            const SizedBox(height: 32),
            _buildQuestionCard(q),
            const SizedBox(height: 48),
            isMultipleChoice ? _buildMultipleChoice(q) : _buildTypingArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    double progress = (_index + 1) / _questions.length;
    return LinearProgressIndicator(
      value: progress, 
      backgroundColor: Colors.orange.withOpacity(0.1), 
      color: Colors.orange,
      minHeight: 6,
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16), 
        border: Border.all(color: Colors.orange.withOpacity(0.2))
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _mode,
          isExpanded: true,
          items: [
            QuizMode.mixed,
            QuizMode.trToEnTyping,
            QuizMode.enToTrTyping,
            QuizMode.trToEnMultipleChoice,
            QuizMode.enToTrMultipleChoice,
          ].map((m) => DropdownMenuItem(value: m, child: Text(QuizMode.label(m)))).toList(),
          onChanged: (v) { if (v != null) { setState(() => _mode = v); _start(); } },
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion q) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.orange.shade600]),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Text(q.expectedLanguage.toUpperCase(), 
               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          Text(q.prompt, textAlign: TextAlign.center, 
               style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildMultipleChoice(QuizQuestion q) {
    return Column(
      children: (q.choices ?? []).map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () => _handleAnswer(c),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white, 
              foregroundColor: Colors.orange, 
              elevation: 0,
              side: BorderSide(color: Colors.orange.withOpacity(0.1), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(c, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildTypingArea() {
    return Column(
      children: [
        TextField(
          key: ValueKey("repeat_field_$_index"),
          controller: _answerCtrl,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Cevabın nedir?",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          ),
          onSubmitted: (val) => _handleAnswer(val),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () => _handleAnswer(_answerCtrl.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange, 
              foregroundColor: Colors.white, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("SIRADAKİ", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorOrEmpty() {
    return Scaffold(body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.sentiment_dissatisfied, size: 64, color: Colors.orange),
      const SizedBox(height: 16),
      Text(_error ?? "Tekrar edilecek kelime bulunamadı."),
      TextButton(onPressed: _start, child: const Text("Yeniden Dene"))
    ])));
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }
}