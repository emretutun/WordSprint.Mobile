import 'package:flutter/material.dart';
import 'package:wordsprint/features/leaderboard/pages/leaderboard_page.dart';
import '../../../core/storage/token_storage.dart';
import '../../auth/pages/login_page.dart';
import '../../profile/models/profile_response.dart';
import '../../profile/models/profile_stats_response.dart';
import '../../profile/services/profile_service.dart';
import '../../learning/pages/learning_page.dart';
import '../../repeat/pages/repeat_page.dart';
import '../../profile/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _profileService = ProfileService();
  bool _loading = true;
  String? _error;
  ProfileResponse? _profile;
  ProfileStatsResponse? _stats;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await _profileService.getProfile();
      final s = await _profileService.getStats();
      if (mounted) {
        setState(() {
          _profile = p;
          _stats = s;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text("Ayrılmak istediğine emin misin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Çıkış", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await TokenStorage.clearToken();
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Daha modern slate rengi
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 3, color: Colors.indigo));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 70),
            const SizedBox(height: 16),
            const Text("Bağlantı Hatası", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text("Yeniden Dene"),
              style: TextButton.styleFrom(foregroundColor: Colors.indigo),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      edgeOffset: 100,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (_profile != null) _buildEnhancedHeader(_profile!),
                const SizedBox(height: 24),
                if (_stats != null) _StatsCard(stats: _stats!),
                const SizedBox(height: 32),
                _buildSectionTitle("Günlük Görevlerin"),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _ActionCard(
                      title: "Öğren",
                      subtitle: "Yeni Kelimeler",
                      icon: Icons.auto_stories_rounded,
                      gradient: const [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningPage())),
                    ),
                    const SizedBox(width: 16),
                    _ActionCard(
                      title: "Tekrar",
                      subtitle: "Bilgini Pekiştir",
                      icon: Icons.psychology_rounded,
                      gradient: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RepeatPage())),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildProfileTile(),
                const SizedBox(height: 32),
                _buildFutureFeatureFooter(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      backgroundColor: const Color(0xFFF1F5F9),
      elevation: 0,
      centerTitle: false,
      title: const Text(
        "WordSprint",
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: Color(0xFF0F172A), letterSpacing: -1),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF64748B)),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
        const Spacer(),
        const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      ],
    );
  }

  Widget _buildEnhancedHeader(ProfileResponse profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [BoxShadow(color: Colors.indigo.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.indigo.shade50,
            backgroundImage: profile.photoUrl.isNotEmpty ? NetworkImage(profile.photoUrl) : null,
            child: profile.photoUrl.isEmpty ? const Icon(Icons.person_rounded, color: Colors.indigo, size: 30) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("İyi günler,", style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(profile.firstName ?? "Gezgin", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
          _load();
        },
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFEEF2FF),
          child: Icon(Icons.settings_suggest_rounded, color: Colors.indigo),
        ),
        title: const Text("Profil ve Ayarlar", style: TextStyle(fontWeight: FontWeight.w700)),
        subtitle: const Text("Hesap bilgilerini güncelle"),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }

  Widget _buildFutureFeatureFooter() {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardPage())),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.indigo.shade900, const Color(0xFF1E293B)]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.amber, size: 32),
            const SizedBox(height: 12),
            const Text("REKABETE KATIL", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 4),
            const Text(
              "Liderlik Tablosu & Başarımlar",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
              child: const Text("Liderlik Tablosuna Git!", style: TextStyle(color: Colors.white54, fontSize: 11)),
            )
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionCard({required this.title, required this.subtitle, required this.icon, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: gradient.last.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: Colors.white),
              const SizedBox(height: 20),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8))),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final ProfileStatsResponse stats;
  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 25, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem("Tamamlanan", stats.totalLearned.toString(), const Color(0xFF2DD4BF)),
              _statItem("Devam Eden", stats.totalLearning.toString(), const Color(0xFF60A5FA)),
              _statItem("Başarı %", stats.successRate.toStringAsFixed(0), const Color(0xFFF87171)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Colors.amber, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Bugün tam ${stats.todayLearned} kelimeyi hafızana attın!",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54, fontWeight: FontWeight.w500)),
      ],
    );
  }
}