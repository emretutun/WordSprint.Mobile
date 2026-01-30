import 'package:flutter/material.dart';
import '../models/learning_word_item.dart';
import '../services/learning_service.dart';
import '../../quiz/pages/quiz_page.dart';


class LearningPage extends StatefulWidget {
  const LearningPage({super.key});

  @override
  State<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage> {
  final _service = LearningService();

  bool _loading = true;
  String? _error;
  List<LearningWordItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await _service.getLearningList();
      setState(() => _items = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _assign10() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _service.assignRandom(count: 10);
      final list = await _service.getLearningList();
      setState(() => _items = list);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Learn New Words"),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Error: $_error"),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _assign10,
                          child: const Text("Assign 10 Random Words"),
                        ),
                        
                      ),
                      SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuizPage()),
                        );
                      },
                      child: const Text("Start Quiz (TR → EN Typing)"),
                    ),
                  ),
                  const SizedBox(height: 12),
                      const SizedBox(height: 12),
                      Text(
                        "Learning list (${_items.length})",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._items.map((w) => Card(
                            child: ListTile(
                              title: Text(w.english),
                              subtitle: Text(w.turkish),
                              trailing: Text("#${w.wordId}"),
                            ),
                          )),
                      if (_items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 24),
                          child: Center(child: Text("No words in learning list.")),
                        ),
                    ],
                  ),
                ),
    );
  }
}
