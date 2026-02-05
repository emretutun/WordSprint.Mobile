import 'package:flutter/material.dart';
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
    await TokenStorage.clearToken();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Daha ferah bir arka plan
      appBar: AppBar(
        title: const Text("WordSprint",
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5, color: Color(0xFF1E293B))),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
            ),
            child: IconButton(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20)),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.indigo));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded, color: Colors.indigo, size: 64),
            const SizedBox(height: 16),
            Text("Veriler yüklenemedi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            TextButton(onPressed: _load, child: const Text("Yeniden Dene", style: TextStyle(color: Colors.indigo))),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: Colors.indigo,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          if (_profile != null) _buildEnhancedHeader(_profile!),
          const SizedBox(height: 25),
          if (_stats != null) _StatsCard(stats: _stats!),
          const SizedBox(height: 30),
          _buildSectionTitle("Bugün Ne Yapıyoruz?"),
          const SizedBox(height: 16),
          Row(
            children: [
              _ActionCard(
                title: "Öğren",
                subtitle: "Yeni Kelimeler",
                icon: Icons.auto_stories_rounded,
                gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LearningPage())),
              ),
              const SizedBox(width: 15),
              _ActionCard(
                title: "Tekrar Et",
                subtitle: "Hafızanı Tazele",
                icon: Icons.psychology_rounded,
                gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RepeatPage())),
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildProfileTile(),
          const SizedBox(height: 40),
          _buildFutureFeatureFooter(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(10))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildEnhancedHeader(ProfileResponse profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Colors.indigo, Colors.blueAccent])),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white,
              backgroundImage: profile.photoUrl.isNotEmpty ? NetworkImage(profile.photoUrl) : null,
              child: profile.photoUrl.isEmpty ? const Icon(Icons.person, color: Colors.indigo) : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hoş geldin,", style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500)),
                Text(profile.firstName ?? "Gezgin", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
              ],
            ),
          ),
          const Icon(Icons.notifications_none_rounded, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildProfileTile() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
      ),
      child: ListTile(
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
          _load();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.indigo.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.person_search_rounded, color: Colors.indigo),
        ),
        title: const Text("Profil Ayarları", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        subtitle: const Text("Hedeflerini ve hesabını yönet", style: TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }

  Widget _buildFutureFeatureFooter() {
    return Opacity(
      opacity: 0.5,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.indigo.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.indigo.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome_rounded, color: Colors.indigo, size: 24),
            const SizedBox(height: 8),
            const Text("YAKINDA", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.indigo)),
            const SizedBox(height: 4),
            const Text("Liderlik Tablosu • Düello Modu • Rozetler", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: gradient.last.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
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
        color: const Color(0xFF1E293B), // Koyu modern tema
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF1E293B).withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem("Öğrenilen", stats.totalLearned.toString(), const Color(0xFF4ADE80)),
              _statItem("Süreçte", stats.totalLearning.toString(), const Color(0xFF60A5FA)),
              _statItem("Başarı", "%${stats.successRate.toStringAsFixed(0)}", const Color(0xFFFBBF24)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Bugün ${stats.todayLearned} kelime kazandın!",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
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
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      ],
    );
  }
}