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
    if (answer.trim().isEmpty &&
        (_mode == QuizMode.trToEnTyping || _mode == QuizMode.enToTrTyping)) {
      return;
    }

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

  String _levelLabel(int level) {
    const levels = ["A1", "A2", "B1", "B2", "C1", "C2"];
    return level >= 0 && level < levels.length ? levels[level] : "?";
  }

  Color _levelColor(int level) {
    switch (level) {
      case 0: return Colors.green;
      case 1: return Colors.teal;
      case 2: return Colors.blue;
      case 3: return Colors.indigo;
      case 4: return Colors.orange;
      case 5: return Colors.red;
      default: return Colors.grey;
    }
  }

  void _showResultDialog(dynamic result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Center(
          child: Text("Sprint Tamamlandı! 🏁", 
            style: TextStyle(fontWeight: FontWeight.w900)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildResultRow("Doğru", "${result.correct}", Colors.green),
            const SizedBox(height: 8),
            _buildResultRow("Yanlış", "${result.wrong}", Colors.red),
            const Divider(height: 32),
            Text(
              "Başarı Oranı: %${result.successRate.toStringAsFixed(0)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              result.passed ? "MÜKEMMEL! 🎉" : "DENEMEYE DEVAM 💪",
              style: TextStyle(
                color: result.passed ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w900,
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
              child: const Text("ANA SAYFAYA DÖN", 
                style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(value, 
          style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 18)),
      ],
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Hata: $_error"),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _start, child: const Text("Tekrar Dene")),
            ],
          ),
        ),
      );
    }

    final q = _questions[_index];
    final bool isChoice = _mode == QuizMode.trToEnMultipleChoice ||
        _mode == QuizMode.enToTrMultipleChoice;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
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
            _buildQuestionCard(q),
            const SizedBox(height: 40),
            isChoice ? _buildMultipleChoice(q) : _buildTypingArea(),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.indigo.withValues(alpha: 0.1),
              color: Colors.indigo,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text("${_index + 1}/${_questions.length}", 
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _mode,
          isExpanded: true,
          items: [
            QuizMode.trToEnTyping,
            QuizMode.enToTrTyping,
            QuizMode.trToEnMultipleChoice,
            QuizMode.enToTrMultipleChoice,
          ].map((m) => DropdownMenuItem(
                value: m, 
                child: Text(QuizMode.label(m), style: const TextStyle(fontSize: 14))
              )).toList(),
          onChanged: (v) {
            if (v == null || v == _mode) return;
            setState(() => _mode = v);
            _start();
          },
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion q) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), 
                blurRadius: 20, 
                offset: const Offset(0, 10)
              )
            ],
          ),
          child: Column(
            children: [
              Text(
                q.expectedLanguage.toUpperCase(),
                style: const TextStyle(
                  color: Colors.indigo, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 2, 
                  fontSize: 11
                ),
              ),
              const SizedBox(height: 16),
              Text(
                q.prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 34, 
                  fontWeight: FontWeight.w900, 
                  color: Color(0xFF1E293B)
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _levelColor(q.level).withValues(alpha: 0.1), 
              borderRadius: BorderRadius.circular(10)
            ),
            child: Text(
              _levelLabel(q.level),
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: _levelColor(q.level), 
                fontSize: 12
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultipleChoice(QuizQuestion q) {
    return Column(
      children: (q.choices ?? []).map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => _handleAnswer(c),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.indigo,
                elevation: 0,
                side: BorderSide(
                  color: Colors.indigo.withValues(alpha: 0.2), 
                  width: 1.5
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)
                ),
              ),
              child: Text(c, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          textAlign: TextAlign.center,
          autofocus: true,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Cevabı buraya yazın...",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20), 
              borderSide: BorderSide.none
            ),
            contentPadding: const EdgeInsets.all(24),
          ),
          onSubmitted: _handleAnswer,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () => _handleAnswer(_answerCtrl.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: Colors.indigo.withValues(alpha: 0.4),
            ),
            child: Text(
              _index == _questions.length - 1 ? "BİTİR" : "DEVAM ET",
              style: const TextStyle(
                fontWeight: FontWeight.w900, 
                fontSize: 16, 
                letterSpacing: 1.2
              ),
            ),
          ),
        ),
      ],
    );
  }
}