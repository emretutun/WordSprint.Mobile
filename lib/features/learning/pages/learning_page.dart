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
      if (mounted) setState(() => _loading = false);
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
      if (mounted) setState(() => _loading = false);
    }
  }

  String _levelLabel(int level) {
    switch (level) {
      case 0: return "A1";
      case 1: return "A2";
      case 2: return "B1";
      case 3: return "B2";
      case 4: return "C1";
      case 5: return "C2";
      default: return "??";
    }
  }

  Color _levelColor(int level) {
    switch (level) {
      case 0: return Colors.green.shade700;
      case 1: return Colors.teal.shade700;
      case 2: return Colors.blue.shade700;
      case 3: return Colors.indigo.shade700;
      case 4: return Colors.orange.shade800;
      case 5: return Colors.red.shade700;
      default: return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text("Kelime Haznesi",
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
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
                  color: Colors.indigo,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      _buildActionPanel(context),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Öğrenilecekler (${_items.length})",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                          ),
                          if (_items.isNotEmpty)
                            const Icon(Icons.sort_by_alpha, size: 20, color: Colors.grey),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_items.isEmpty)
                        _buildEmptyState()
                      else
                        ..._items.map((w) => _buildWordCard(w)),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
    );
  }

  Widget _buildActionPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // shadow rengi için withValues kullanımı
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Bugün kaç kelime devireceksin?",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _assign10,
            icon: const Icon(Icons.bolt_rounded, size: 22),
            label: const Text("10 YENİ KELİME EKLE", style: TextStyle(fontWeight: FontWeight.w800)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo.shade800,
              minimumSize: const Size(double.infinity, 56),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const QuizPage())),
            icon: const Icon(Icons.play_circle_fill_rounded, size: 22),
            label: const Text("QUIZ'E BAŞLA", style: TextStyle(fontWeight: FontWeight.w800)),
            style: OutlinedButton.styleFrom(
              // border rengi için alpha kullanımı
              side: BorderSide(color: Colors.white.withValues(alpha: 0.24), width: 2),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(LearningWordItem w) {
    final levelText = _levelLabel(w.level);
    final levelColor = _levelColor(w.level);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: levelColor),
              Expanded(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          w.english,
                          style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          // Seviye rozet arka planı için değer
                          color: levelColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          levelText,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: levelColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      w.turkish,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700),
                    ),
                  ),
                  trailing: Material(
                    color: Colors.grey.shade100,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        // Ses işlevi butonu
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(Icons.volume_up_rounded, size: 22, color: Colors.indigo.shade400),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.indigo.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_stories_rounded, size: 80, color: Colors.indigo.shade300),
          ),
          const SizedBox(height: 24),
          const Text(
            "Listen şu an boş.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 8),
          const Text(
            "Yeni kelimeler ekleyerek sprint'e başla!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 80, color: Colors.redAccent),
            const SizedBox(height: 24),
            Text(
              "Bir şeyler ters gitti",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red.shade900),
            ),
            const SizedBox(height: 8),
            Text("$_error", textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("YENİDEN DENE")),
          ],
        ),
      ),
    );
  }
}