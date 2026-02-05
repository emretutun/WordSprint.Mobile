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
  int _mode = QuizMode.enToTrTyping;

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
    if (answer.trim().isEmpty && !_mode.toString().contains('Choice')) return;

    final q = _questions[_index];
    _answers.add(SubmitAnswer(wordId: q.wordId, answer: answer.trim()));
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
        title: const Column(
          children: [
            Icon(Icons.auto_awesome, color: Colors.orange, size: 48),
            SizedBox(height: 16),
            Text("Hafıza Tazelendi!", textAlign: TextAlign.center),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildResultRow("Doğru", "${result.correct}", Colors.green),
            _buildResultRow("Yanlış", "${result.wrong}", Colors.red),
            const Divider(height: 32),
            Text(
              "%${result.successRate.toStringAsFixed(0)} Başarı",
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.orange),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text("ANA SAYFAYA DÖN", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.orange)));

    if (_error != null || _questions.isEmpty) return _buildErrorOrEmpty();

    final q = _questions[_index];
    final bool isMultipleChoice = _mode == QuizMode.trToEnMultipleChoice || _mode == QuizMode.enToTrMultipleChoice;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildProgressHeader(),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildModeSelector(),
            const SizedBox(height: 32),
            
            // Soru Kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      q.expectedLanguage.toUpperCase(), 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    q.prompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Cevap Alanı
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isMultipleChoice ? _buildMultipleChoice(q) : _buildTypingArea(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    double progress = (_index + 1) / _questions.length;
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              color: Colors.orange,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${_index + 1} / ${_questions.length}", 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: DropdownButton<int>(
        value: _mode,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.tune_rounded, color: Colors.orange),
        items: [QuizMode.trToEnTyping, QuizMode.enToTrTyping, QuizMode.trToEnMultipleChoice, QuizMode.enToTrMultipleChoice]
            .map((m) => DropdownMenuItem(value: m, child: Text(QuizMode.label(m), style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
        onChanged: (v) { if (v != null) { setState(() => _mode = v); _start(); } },
      ),
    );
  }

  Widget _buildMultipleChoice(QuizQuestion q) {
    return Column(
      key: ValueKey("choice_$_index"),
      children: (q.choices ?? []).map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () => _handleAnswer(c),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange.shade800,
              elevation: 0,
              side: BorderSide(color: Colors.orange.withValues(alpha: 0.1), width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(c, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildTypingArea() {
    return Column(
      key: ValueKey("typing_$_index"),
      children: [
        TextField(
          controller: _answerCtrl,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF2D3142)),
          decoration: InputDecoration(
            hintText: "Cevabın nedir?",
            hintStyle: TextStyle(color: Colors.grey.shade300),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24), 
              borderSide: BorderSide(color: Colors.orange.withValues(alpha: 0.1), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24), 
              borderSide: BorderSide(color: Colors.orange.withValues(alpha: 0.1), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24), 
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
            contentPadding: const EdgeInsets.all(28),
          ),
          onSubmitted: (val) => _handleAnswer(val),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: () => _handleAnswer(_answerCtrl.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 8,
              shadowColor: Colors.orange.withValues(alpha: 0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _index == _questions.length - 1 ? "TAMAMLA" : "SIRADAKİ",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorOrEmpty() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sentiment_dissatisfied_rounded, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              Text(
                _error ?? "Henüz tekrar edilecek kelime yok.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _start, 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("Yeniden Dene"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}