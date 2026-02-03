import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../models/submit_quiz_models.dart';
import '../services/quiz_service.dart';
import '../models/quiz_mode.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _service = QuizService();

  bool _loading = true;
  String? _error;

  List<QuizQuestion> _questions = [];
  int _index = 0;

  final _answerCtrl = TextEditingController();
  final List<SubmitAnswer> _answers = [];

  // Varsayılan mod
  int _mode = QuizMode.trToEnTyping;

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
      final res = await _service.start(count: 10, mode: _mode);
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
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.submit(
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
        title: const Center(child: Text("Sprint Tamamlandı! 🏁")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildResultRow("Doğru", "${result.correct}", Colors.green),
            _buildResultRow("Yanlış", "${result.wrong}", Colors.red),
            const Divider(height: 32),
            Text(
              "Başarı Oranı: %${result.successRate.toStringAsFixed(0)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              result.passed ? "TEBRİKLER! 🎉" : "BİRAZ DAHA ÇALIŞMALISIN 💪",
              style: TextStyle(
                color: result.passed ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialog kapat
                Navigator.pop(context); // Quiz'den çık
              },
              child: const Text("TAMAM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
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
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text("Hata: $_error", textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(onPressed: _start, child: const Text("Tekrar Dene")),
              ],
            ),
          ),
        ),
      );
    }

    final q = _questions[_index];
    final bool isMultipleChoice = _mode == QuizMode.trToEnMultipleChoice || 
                                 _mode == QuizMode.enToTrMultipleChoice;

    return Scaffold(
      backgroundColor: Colors.grey[50],
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
            const SizedBox(height: 32),
            
            // Soru Kartı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Column(
                children: [
                  Text(
                    q.expectedLanguage.toUpperCase(), 
                    style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    q.prompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
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
            backgroundColor: Colors.indigo.withValues(),
            color: Colors.indigo,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          "${_index + 1}/${_questions.length}", 
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButton<int>(
        value: _mode,
        isExpanded: true,
        underline: const SizedBox(),
        items: [
          QuizMode.trToEnTyping,
          QuizMode.enToTrTyping,
          QuizMode.trToEnMultipleChoice,
          QuizMode.enToTrMultipleChoice,
        ].map((m) {
          return DropdownMenuItem(
            value: m,
            child: Text(QuizMode.label(m), style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: (v) {
          if (v == null || v == _mode) return;
          setState(() => _mode = v);
          _start();
        },
      ),
    );
  }

  Widget _buildMultipleChoice(QuizQuestion q) {
    final choices = q.choices ?? [];
    return Column(
      children: choices.map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => _handleAnswer(c),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo,
                elevation: 0,
                side: BorderSide(color: Colors.indigo.withValues(), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(c, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            ),
          ),
        );
      }).toList(),
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
            hintText: "Cevabı buraya yazın...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(24),
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
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white, // Yazının okunabilirliği için beyaz yapıldı
              elevation: 4,
              shadowColor: Colors.indigo.withValues(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: Text(
              _index == _questions.length - 1 ? "BİTİR" : "SIRADAKİ SORU",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
          ),
        ),
      ],
    );
  }
}