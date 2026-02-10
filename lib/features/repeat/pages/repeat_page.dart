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
  List<LearnedWordItem> _allItems = [];
  List<LearnedWordItem> _filteredItems = [];
  int? _selectedLevel;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final list = await _service.getLearnedList();
      setState(() {
        _allItems = list;
        _applyFilter();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    if (_selectedLevel == null) {
      _filteredItems = List.from(_allItems);
    } else {
      _filteredItems = _allItems.where((w) => w.level == _selectedLevel).toList();
    }
  }

  String _levelLabel(int level) {
    return ["A1", "A2", "B1", "B2", "C1", "C2"][level];
  }

  Color _levelColor(int level) {
    return [
      Colors.green, Colors.teal, Colors.blue, 
      const Color(0xFF6366F1), Colors.orange, Colors.red
    ][level];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFB), 
      appBar: AppBar(
        title: const Text("Hafıza Merkezi", 
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF1F2937),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.sync_rounded)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _error != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: Colors.orange,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      const SizedBox(height: 10),
                      _buildHeaderPanel(context),
                      const SizedBox(height: 25),
                      _buildFilterLabel(),
                      const SizedBox(height: 12),
                      _buildHorizontalLevelFilter(),
                      const SizedBox(height: 25),
                      _buildSectionHeader(),
                      const SizedBox(height: 15),
                      if (_filteredItems.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) => _buildLearnedCard(_filteredItems[index]),
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _buildFilterLabel() {
    return Row(
      children: [
        const Icon(Icons.tune_rounded, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text("SEVİYE SEÇ", style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey.shade600, letterSpacing: 1.2
        )),
      ],
    );
  }

  
  Widget _buildHorizontalLevelFilter() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: 7,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final levelValue = isAll ? null : index - 1;
          final isSelected = _selectedLevel == levelValue;
          
          return ChoiceChip(
            label: Text(isAll ? "Hepsi" : _levelLabel(levelValue!)),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedLevel = levelValue;
                _applyFilter();
              });
            },
            selectedColor: Colors.orange.shade600,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            elevation: isSelected ? 4 : 0,
            pressElevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade200),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.psychology_rounded, size: 40, color: Colors.white),
          const SizedBox(height: 12),
          const Text("Bilgilerini Taze Tut", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text("Öğrendiğin kelimeleri düzenli tekrar ederek kalıcı hafızaya aktar.",
            textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const RepeatQuizPage()));
              _load();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange.shade800,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text("TEKRAR QUIZ'İ BAŞLAT", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 10),
        Text("Feth edilen Kelimeler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.grey.shade800)),
        const Spacer(),
        Text("${_filteredItems.length}", style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.green)),
      ],
    );
  }

  Widget _buildLearnedCard(LearnedWordItem w) {
    final color = _levelColor(w.level);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(Icons.verified_rounded, color: color, size: 22),
        ),
        title: Text(w.english, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1F2937))),
        subtitle: Text(w.turkish, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Text(_levelLabel(w.level), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12)),
        ),
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.auto_awesome_rounded, size: 80, color: Colors.orange.withValues(alpha: 0.1)),
          const SizedBox(height: 20),
          const Text("Burası Henüz Sessiz", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text("Öğrenilen kelimeler burada birikecek.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text("$_error"),
          TextButton(onPressed: _load, child: const Text("Yeniden Dene")),
        ],
      ),
    );
  }
}