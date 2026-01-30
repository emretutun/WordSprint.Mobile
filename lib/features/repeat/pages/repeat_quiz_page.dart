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

  int _mode = QuizMode.enToTrTyping; // repeat için default güzel

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
    final q = _questions[_index];
    final ans = _answerCtrl.text.trim();

    _answers.add(SubmitAnswer(wordId: q.wordId, answer: ans));
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
      final result = await _service.submitRepeat(
        SubmitQuizRequest(mode: _mode, answers: _answers),
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Repeat Result"),
          content: Text(
            "Total: ${result.total}\n"
            "Correct: ${result.correct}\n"
            "Wrong: ${result.wrong}\n"
            "Success: ${result.successRate.toStringAsFixed(2)}%\n"
            "Passed: ${result.passed}",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // close page
              },
              child: const Text("OK"),
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
        appBar: AppBar(title: Text("Repeat Quiz")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Repeat Quiz")),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Error: $_error"),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _start,
                  child: const Text("Retry"),
                )
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Repeat Quiz")),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("No learned words to repeat yet."),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _start,
                child: const Text("Try Again"),
              ),
            ],
          ),
        ),
      );
    }

    final q = _questions[_index];

    // Answer widget
    Widget answerWidget;

    if (_mode == QuizMode.trToEnMultipleChoice || _mode == QuizMode.enToTrMultipleChoice) {
      final choices = q.choices ?? [];
      answerWidget = choices.isEmpty
          ? const Text("No choices returned from API.")
          : Column(
              children: choices.map((c) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        _answers.add(SubmitAnswer(wordId: q.wordId, answer: c));
                        if (_index < _questions.length - 1) {
                          setState(() => _index++);
                        } else {
                          _submit();
                        }
                      },
                      child: Text(c),
                    ),
                  ),
                );
              }).toList(),
            );
    } else {
      answerWidget = Column(
        children: [
          TextField(
            controller: _answerCtrl,
            decoration: const InputDecoration(
              labelText: "Your answer",
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _nextTyping(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextTyping,
              child: Text(_index == _questions.length - 1 ? "Submit" : "Next"),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Repeat ${_index + 1}/${_questions.length}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<int>(
              value: _mode,
              decoration: const InputDecoration(
                labelText: "Question Mode",
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
                if (v == null) return;
                setState(() => _mode = v);
                _start();
              },
            ),
            const SizedBox(height: 16),
            Text(
              q.prompt,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text("Expected: ${q.expectedLanguage}"),
            const SizedBox(height: 16),
            answerWidget,
          ],
        ),
      ),
    );
  }
}
