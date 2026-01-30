import 'package:flutter/material.dart';
import '../models/profile_response.dart';
import '../models/update_profile_request.dart';
import '../services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileResponse initial;

  const EditProfilePage({super.key, required this.initial});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _service = ProfileService();

  late final TextEditingController _firstCtrl;
  late final TextEditingController _lastCtrl;
  late final TextEditingController _goalCtrl;
  late final TextEditingController _levelCtrl;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _firstCtrl = TextEditingController(text: widget.initial.firstName ?? "");
    _lastCtrl = TextEditingController(text: widget.initial.lastName ?? "");
    _goalCtrl = TextEditingController(text: widget.initial.dailyWordGoal.toString());
    _levelCtrl = TextEditingController(text: widget.initial.estimatedLevel ?? "");
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _goalCtrl.dispose();
    _levelCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final goal = int.tryParse(_goalCtrl.text.trim());

      final req = UpdateProfileRequest(
        firstName: _firstCtrl.text.trim(),
        lastName: _lastCtrl.text.trim(),
        dailyWordGoal: goal,
        estimatedLevel: _levelCtrl.text.trim().isEmpty ? null : _levelCtrl.text.trim(),
      );

      await _service.updateProfile(req);

      if (!mounted) return;
      Navigator.pop(context, true); // updated
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _firstCtrl,
              decoration: const InputDecoration(labelText: "First name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _lastCtrl,
              decoration: const InputDecoration(labelText: "Last name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _goalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Daily word goal (1-100)"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _levelCtrl,
              decoration: const InputDecoration(labelText: "Estimated level (optional)"),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _save,
                child: Text(_loading ? "Saving..." : "Save"),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}
