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

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Quiz Sonucu"),
          content: Text(
            "Toplam: ${result.total}\n"
            "Doğru: ${result.correct}\n"
            "Yanlış: ${result.wrong}\n"
            "Başarı: %${result.successRate.toStringAsFixed(2)}\n"
            "Durum: ${result.passed ? 'Geçti' : 'Kaldı'}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dialog kapat
                Navigator.pop(context); // Quiz sayfasından çık
              },
              child: const Text("Tamam"),
            )
          ],
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _answerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Hata: $_error", textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _start, child: const Text("Tekrar Dene")),
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Soru bulunamadı."),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _start, child: const Text("Başlat")),
            ],
          ),
        ),
      );
    }

    final q = _questions[_index];
    final bool isMultipleChoice = _mode == QuizMode.trToEnMultipleChoice || 
                                 _mode == QuizMode.enToTrMultipleChoice;

    return Scaffold(
      appBar: AppBar(
        title: Text("Soru ${_index + 1}/${_questions.length}"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              value: _mode,
              decoration: const InputDecoration(
                labelText: "Soru Modu",
                border: OutlineInputBorder(),
              ),
              items: const [
                QuizMode.trToEnTyping,
                QuizMode.enToTrTyping,
                QuizMode.trToEnMultipleChoice,
                QuizMode.enToTrMultipleChoice,
              ].map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(QuizMode.label(m)),
                );
              }).toList(),
              onChanged: (v) {
                if (v == null || v == _mode) return;
                setState(() => _mode = v);
                _start();
              },
            ),
            const SizedBox(height: 24),
            Text(
              q.prompt,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Beklenen Dil: ${q.expectedLanguage}", 
                 style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 24),
            
            // Cevap Alanı
            if (isMultipleChoice) 
              _buildMultipleChoice(q)
            else 
              _buildTypingArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleChoice(QuizQuestion q) {
    final choices = q.choices ?? [];
    if (choices.isEmpty) return const Text("Seçenekler yüklenemedi.");

    return Column(
      children: choices.map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => _handleAnswer(c),
              child: Text(c, style: const TextStyle(fontSize: 16)),
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
          decoration: const InputDecoration(
            labelText: "Cevabınızı yazın",
            border: OutlineInputBorder(),
          ),
          onSubmitted: (val) => _handleAnswer(val),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => _handleAnswer(_answerCtrl.text),
            child: Text(_index == _questions.length - 1 ? "Gönder" : "Sıradaki Soru"),
          ),
        ),
      ],
    );
  }
}