import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/forgot_password_code_request.dart';
import 'verify_reset_code_page.dart';

class ForgotPasswordCodePage extends StatefulWidget {
  const ForgotPasswordCodePage({super.key});

  @override
  State<ForgotPasswordCodePage> createState() => _ForgotPasswordCodePageState();
}

class _ForgotPasswordCodePageState extends State<ForgotPasswordCodePage> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  final _authService = AuthService();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email boş olamaz")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.forgotPasswordCode(
        ForgotPasswordCodeRequest(email: email),
      );

      if (!mounted) return;

      // Kod ekranına geç
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyResetCodePage(email: email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kod gönderilemedi: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Şifremi Unuttum")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                hintText: "ornek@mail.com",
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendCode,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Kod Gönder"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
