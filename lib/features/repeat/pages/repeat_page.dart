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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Kelime Tekrarı", style: TextStyle(fontWeight: FontWeight.bold)),
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
                      // 1. Motivasyon ve Aksiyon Paneli
                      _buildHeaderPanel(context),
                      
                      const SizedBox(height: 25),
                      
                      Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Öğrenilen Kelimeler (${_items.length})",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 15),
                      
                      if (_items.isEmpty)
                        _buildEmptyState()
                      else
                        ..._items.map((w) => _buildLearnedCard(w)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeaderPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Hafızanı Tazele!",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Öğrendiğin kelimeleri unutmamak için düzenli tekrar yapmalısın.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RepeatQuizPage()),
              );
              _load();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange.shade700,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Text("Tekrar Quiz'ini Başlat", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnedCard(LearnedWordItem w) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Colors.green, size: 20),
        ),
        title: Text(
          w.english,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        subtitle: Text(
          w.turkish,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        trailing: Text(
          "#${w.wordId}",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Icon(Icons.history_edu, size: 80, color: Colors.orange.withValues()),
        const SizedBox(height: 20),
        const Text(
          "Henüz öğrenilmiş kelime yok.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        const Text(
          "Öğrenme listesindeki kelimeleri tamamla ve burada gör!",
          textAlign: TextAlign.center,
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
          Text("Hata: $_error"),
          ElevatedButton(onPressed: _load, child: const Text("Tekrar Dene")),
        ],
      ),
    );
  }
}