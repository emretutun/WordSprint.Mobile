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
    setState(() { _loading = true; _error = null; });
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
    setState(() { _loading = true; _error = null; });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Kelime Haznesi", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      // Üst Aksiyon Paneli
                      _buildActionPanel(context),
                      
                      const SizedBox(height: 25),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Öğrenilecekler (${_items.length})",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (_items.isNotEmpty)
                            const Icon(Icons.sort_by_alpha, size: 20, color: Colors.grey),
                        ],
                      ),
                      
                      const SizedBox(height: 15),
                      
                      if (_items.isEmpty)
                        _buildEmptyState()
                      else
                        ..._items.map((w) => _buildWordCard(w)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildActionPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _assign10,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("10 Yeni Kelime Ekle"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizPage())),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text("Quiz'e Başla (Yazma)"),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.indigo),
              foregroundColor: Colors.indigo,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(LearningWordItem w) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          w.english,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            w.turkish,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
          child: const Icon(Icons.volume_up, size: 20, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 50),
        Icon(Icons.auto_stories_outlined, size: 80, color: Colors.indigo.withValues()),
        const SizedBox(height: 20),
        const Text(
          "Listen şu an boş.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        const Text(
          "Yeni kelimeler ekleyerek sprint'e başla!",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text("Bir şeyler ters gitti: $_error"),
          ElevatedButton(onPressed: _load, child: const Text("Yeniden Dene")),
        ],
      ),
    );
  }
}