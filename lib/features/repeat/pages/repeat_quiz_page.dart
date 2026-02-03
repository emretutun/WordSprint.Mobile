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

  void _nextTyping() {
    if (_answerCtrl.text.trim().isEmpty) return;
    final q = _questions[_index];
    _answers.add(SubmitAnswer(wordId: q.wordId, answer: _answerCtrl.text.trim()));
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Center(child: Text("Hafıza Tazelendi! 🧠")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _resultRow("Doğru", "${result.correct}", Colors.green),
            _resultRow("Yanlış", "${result.wrong}", Colors.red),
            const Divider(height: 30),
            Text("Başarı Oranı: %${result.successRate.toStringAsFixed(0)}", 
                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () { Navigator.pop(context); Navigator.pop(context); },
              child: const Text("HARİKA", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (_error != null || _questions.isEmpty) return _buildErrorOrEmpty();

    final q = _questions[_index];
    final bool isMultipleChoice = _mode == QuizMode.trToEnMultipleChoice || _mode == QuizMode.enToTrMultipleChoice;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: _buildProgressHeader(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildModeSelector(),
            const SizedBox(height: 40),
            
            // Soru Kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.orange.shade50, // Repeat için turuncu tonu
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.orange.shade100, width: 2),
              ),
              child: Column(
                children: [
                  Text("LÜTFEN ŞU DİLE ÇEVİR: ${q.expectedLanguage.toUpperCase()}", 
                       style: TextStyle(color: Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
                  const SizedBox(height: 20),
                  Text(q.prompt, textAlign: TextAlign.center,
                       style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Cevap Alanı
            isMultipleChoice ? _buildMultipleChoice(q) : _buildTypingArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    double progress = (_index + 1) / _questions.length;
    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.orange.withValues(),
            color: Colors.orange,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 16),
        Text("${_index + 1}/${_questions.length}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50, 
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButton<int>(
        value: _mode,
        isExpanded: true,
        underline: const SizedBox(),
        items: [QuizMode.trToEnTyping, QuizMode.enToTrTyping, QuizMode.trToEnMultipleChoice, QuizMode.enToTrMultipleChoice]
            .map((m) => DropdownMenuItem(value: m, child: Text(QuizMode.label(m)))).toList(),
        onChanged: (v) { if (v != null) { setState(() => _mode = v); _start(); } },
      ),
    );
  }

  Widget _buildMultipleChoice(QuizQuestion q) {
    return Column(
      children: (q.choices ?? []).map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {
              _answers.add(SubmitAnswer(wordId: q.wordId, answer: c));
              if (_index < _questions.length - 1) { setState(() => _index++); } else { _submit(); }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange.shade800,
              elevation: 0,
              side: BorderSide(color: Colors.orange.shade100, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(c, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildTypingArea() {
    return Column(
      children: [
        TextField(
          controller: _answerCtrl,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Cevabınızı buraya yazın...",
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.all(24),
          ),
          onSubmitted: (_) => _nextTyping(),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: _nextTyping,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white, // Okunabilir beyaz metin
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 4,
              shadowColor: Colors.orange.withValues(),
            ),
            child: Text(
              _index == _questions.length - 1 ? "TAMAMLA" : "SIRADAKİ",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorOrEmpty() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? "Henüz tekrar edilecek kelime yok."),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _start, child: const Text("Yeniden Dene")),
          ],
        ),
      ),
    );
  }
}