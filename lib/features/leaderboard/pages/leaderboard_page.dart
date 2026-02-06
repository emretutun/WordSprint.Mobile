import 'package:flutter/material.dart';
import '../models/leaderboard_item.dart';
import '../services/leaderboard_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin {
  final _service = LeaderboardService();
  late final TabController _tab;
  bool _loading = true;
  String? _error;

  List<LeaderboardItem> _days = [];
  List<LeaderboardItem> _learned = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final days = await _service.getTopDays(limit: 20);
      final learned = await _service.getTopLearned(limit: 20);
      if (mounted) {
        setState(() {
          _days = days;
          _learned = learned;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Sıralama Dağı",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.sync_rounded, color: Colors.indigo)),
        ],
        bottom: TabBar(
          controller: _tab,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 4, color: Colors.indigo),
            insets: EdgeInsets.symmetric(horizontal: 40),
          ),
          labelColor: Colors.indigo,
          unselectedLabelColor: Colors.blueGrey,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          tabs: const [
            Tab(text: "Seri Günü"),
            Tab(text: "Toplam Kelime"),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.indigo))
          : _error != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tab,
                  children: [
                    _buildFullList(_days, "gün"),
                    _buildFullList(_learned, "kelime"),
                  ],
                ),
    );
  }

  Widget _buildFullList(List<LeaderboardItem> items, String unit) {
    if (items.isEmpty) return _buildEmpty();

    return RefreshIndicator(
      onRefresh: _load,
      color: Colors.indigo,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final rank = index + 1;
          if (rank <= 3) {
            return _buildTopThreeTile(item, rank, unit);
          }
          return _buildStandardTile(item, rank, unit);
        },
      ),
    );
  }

  Widget _buildTopThreeTile(LeaderboardItem item, int rank, String unit) {
    final score = unit == "gün" ? (item.daysLearning ?? 0) : (item.learnedCount ?? 0);
    final List<Color> colors = rank == 1
        ? [const Color(0xFFFFD700), const Color(0xFFFFA000)]
        : rank == 2
            ? [const Color(0xFFC0C0C0), const Color(0xFF90A4AE)]
            : [const Color(0xFFCD7F32), const Color(0xFFA1887F)];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: colors.first.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(22)),
          child: Row(
            children: [
              Text(rank == 1 ? "🥇" : rank == 2 ? "🥈" : "🥉", style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              _buildUserAvatar(item, rank),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name ?? "Anonim",
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF1E293B))),
                    Text(item.email ?? "", style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(score.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 20, color: Colors.indigo)),
                  Text(unit,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          color: Colors.indigo,
                          letterSpacing: 1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardTile(LeaderboardItem item, int rank, String unit) {
    final score = unit == "gün" ? (item.daysLearning ?? 0) : (item.learnedCount ?? 0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(rank.toString(),
                style: const TextStyle(
                    fontWeight: FontWeight.w900, color: Colors.blueGrey, fontSize: 16)),
          ),
          _buildUserAvatar(item, rank),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name ?? "Anonim",
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF334155))),
                if (item.email != null)
                  Text(item.email!, style: const TextStyle(color: Colors.blueGrey, fontSize: 11)),
              ],
            ),
          ),
          Text(
            "$score $unit",
            style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.blueGrey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(LeaderboardItem item, int rank) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: rank <= 3 ? Colors.indigo : Colors.grey.shade200,
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: rank <= 3 ? 24 : 20,
        backgroundColor: Colors.indigo.shade50,
        child: Text(item.name?[0].toUpperCase() ?? "U",
            style: TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.bold,
                fontSize: rank <= 3 ? 18 : 15)),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 60),
          const SizedBox(height: 16),
          Text("Hata: $_error",
              textAlign: TextAlign.center, style: const TextStyle(color: Colors.blueGrey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _load,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Tekrar Dene"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined, size: 80, color: Color(0xFFE2E8F0)),
          SizedBox(height: 16),
          Text("Henüz kimse tırmanışa başlamadı!",
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ],
      ),
    );
  }
}