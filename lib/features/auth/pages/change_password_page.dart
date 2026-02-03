import 'package:flutter/material.dart';
import 'package:wordsprint/features/profile/models/change_password_request.dart';
import '../services/auth_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _auth = AuthService();

  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _change() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _auth.changePassword(
        ChangePasswordRequest(
          currentPassword: _currentCtrl.text,
          newPassword: _newCtrl.text,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed ✅")),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Current password"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _newCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New password"),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _change,
                child: Text(_loading ? "Changing..." : "Change password"),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
