import 'package:flutter/material.dart';
import '../models/reset_password_request.dart';
import '../services/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _auth = AuthService();

  final _userIdCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _reset() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _auth.resetPassword(
        ResetPasswordRequest(
          userId: _userIdCtrl.text.trim(),
          token: _tokenCtrl.text.trim(),
          newPassword: _passCtrl.text,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password reset ✅ You can login now.")),
      );

      Navigator.popUntil(context, (r) => r.isFirst); // login'e dön
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _userIdCtrl.dispose();
    _tokenCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Paste userId and token from email, then set a new password.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _userIdCtrl,
              decoration: const InputDecoration(labelText: "UserId"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tokenCtrl,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Token"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New password"),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _reset,
                child: Text(_loading ? "Resetting..." : "Reset password"),
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
