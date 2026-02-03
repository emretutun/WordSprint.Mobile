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
  String? _error; // Hata mesajını artık UI'da kullanıyoruz
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("WordSprint",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.indigo)),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hata oluştuysa kullanıcıya göster ve tekrar deneme butonu koy
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text("Bir hata oluştu: $_error"),
            TextButton(onPressed: _load, child: const Text("Tekrar Dene")),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          if (_profile != null) _buildWelcomeHeader(_profile!),
          const SizedBox(height: 25),
          if (_stats != null) _StatsCard(stats: _stats!),
          const SizedBox(height: 30),
          const Text("Bugün Ne Yapıyoruz?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              _ActionCard(
                title: "Öğren",
                subtitle: "Yeni Kelimeler",
                icon: Icons.auto_stories,
                color: Colors.indigo,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LearningPage())),
              ),
              const SizedBox(width: 15),
              _ActionCard(
                title: "Tekrar Et",
                subtitle: "Hafızanı Tazele",
                icon: Icons.psychology,
                color: Colors.orange,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RepeatPage())),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ListTile(
            onTap: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()));
              _load();
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tileColor: Colors.white,
            leading: const CircleAvatar(
                backgroundColor: Colors.indigo,
                child: Icon(Icons.person, color: Colors.white)),
            title: const Text("Profil Detayları",
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: const Icon(Icons.chevron_right),
          ),
          const SizedBox(height: 30),
          const Opacity(
            opacity: 0.6,
            child: Column(
              children: [
                Divider(),
                Text("YAKINDA: Liderlik Tablosu & Günlük Quizler",
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(ProfileResponse profile) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundImage: profile.photoUrl.isNotEmpty
              ? NetworkImage(profile.photoUrl)
              : null,
          backgroundColor: Colors.indigo.shade100,
          child: profile.photoUrl.isEmpty
              ? const Icon(Icons.person, size: 30, color: Colors.indigo)
              : null,
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Merhaba,",
                  style: TextStyle(color: Colors.grey[600], fontSize: 16)),
              Text(
                profile.firstName ?? "Gezgin",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // GÜNCELLEME: withOpacity yerine withValues kullanıldı
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 12),
              Text(title,
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(subtitle,
                  style:
                      TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8))),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statItem("Öğrenilen", stats.totalLearned.toString(), Colors.green),
              _statItem("Süreçte", stats.totalLearning.toString(), Colors.blue),
              _statItem("Başarı", "%${stats.successRate.toStringAsFixed(0)}",
                  Colors.orange),
            ],
          ),
          const Divider(height: 30),
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                "Bugün ${stats.todayLearned} yeni kelime öğrendin!",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }
}