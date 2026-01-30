import 'package:flutter/material.dart';
import '../../../core/storage/token_storage.dart';
import '../../auth/pages/login_page.dart';
import '../../profile/models/profile_response.dart';
import '../../profile/models/profile_stats_response.dart';
import '../../profile/services/profile_service.dart';
import '../../learning/pages/learning_page.dart';
import '../../repeat/pages/repeat_page.dart';


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
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final p = await _profileService.getProfile();
      final s = await _profileService.getStats();

      setState(() {
        _profile = p;
        _stats = s;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
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
      appBar: AppBar(
        title: const Text("WordSprint"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
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
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _ProfileCard(profile: _profile!),
                      const SizedBox(height: 12),
                      _StatsCard(stats: _stats!),
                      const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LearningPage()),
                            );
                          },
                          child: const Text("Learn New Words"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RepeatPage()),
                            );
                          },
                          child: const Text("Repeat"),
                        ),
                      ),
                    ],
                  ),
                      const SizedBox(height: 16),
                      const Text(
                        "Next:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text("• Learning screen (new words)"),
                      const Text("• Quiz screen (4 modes)"),
                      const Text("• Repeat screen (learned words)"),
                    ],
                  ),
                ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final ProfileResponse profile;

  const _ProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final fullName = "${profile.firstName ?? ""} ${profile.lastName ?? ""}".trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(profile.photoUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName.isEmpty ? profile.email : fullName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(profile.email),
                  const SizedBox(height: 4),
                  Text("Daily goal: ${profile.dailyWordGoal}"),
                ],
              ),
            ),
          ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Stats", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Learned: ${stats.totalLearned}"),
            Text("Learning: ${stats.totalLearning}"),
            Text("Correct/Wrong: ${stats.totalCorrect}/${stats.totalWrong}"),
            Text("Success: ${stats.successRate.toStringAsFixed(2)}%"),
            Text("Today learned: ${stats.todayLearned}"),
          ],
        ),
      ),
    );
  }
}
