import 'package:flutter/material.dart';
import '../models/profile_response.dart';
import '../services/profile_service.dart';
import 'edit_profile_page.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _service = ProfileService();

  bool _loading = true;
  String? _error;
  ProfileResponse? _profile;

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
      final p = await _service.getProfile();
      setState(() => _profile = p);
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
        title: const Text("Profile"),
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
              : _profile == null
                  ? const Center(child: Text("No profile data."))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 44,
                            backgroundImage: NetworkImage(_profile!.photoUrl),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _profile!.email,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text("Name: ${(_profile!.firstName ?? "")} ${(_profile!.lastName ?? "")}".trim()),
                                const SizedBox(height: 8),
                                Text("Daily goal: ${_profile!.dailyWordGoal}"),
                                const SizedBox(height: 8),
                                Text("Estimated level: ${_profile!.estimatedLevel ?? "-"}"),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfilePage(initial: _profile!),
                          ),
                        );

                        if (updated == true) {
                          _load(); // profili yeniden çek
                        }
                      },
                      child: const Text("Edit Profile"),
                    ),
                  ),
                        const SizedBox(height: 12),
                        const Text("Next: Edit profile + upload photo"),
                      ],
                    ),
    );
  }
}
