import 'package:flutter/material.dart';
import '../models/learned_word_item.dart';
import '../services/repeat_service.dart';
import 'repeat_quiz_page.dart';

class RepeatPage extends StatefulWidget {
  const RepeatPage({super.key});

  @override
  State<RepeatPage> createState() => _RepeatPageState();
}

class _RepeatPageState extends State<RepeatPage> {
  final _service = RepeatService();

  bool _loading = true;
  String? _error;
  List<LearnedWordItem> _items = [];

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
      final list = await _service.getLearnedList();
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
        title: const Text("Repeat"),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          )
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
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RepeatQuizPage()),
                            );
                            // quiz sonrası liste değişebilir (yanlışlarla learning'e düşebilir)
                            _load();
                          },
                          child: const Text("Start Repeat Quiz"),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Learned words (${_items.length})",
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
                          child: Center(child: Text("You have no learned words yet.")),
                        ),
                    ],
                  ),
                ),
    );
  }
}
