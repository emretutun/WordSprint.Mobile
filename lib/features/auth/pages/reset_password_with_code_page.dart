import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/reset_password_with_code_request.dart';
// Login sayfanın yolu sende farklıysa importu düzelt
// import 'login_page.dart';

class ResetPasswordWithCodePage extends StatefulWidget {
  final String email;
  final String code;

  const ResetPasswordWithCodePage({
    super.key,
    required this.email,
    required this.code,
  });

  @override
  State<ResetPasswordWithCodePage> createState() =>
      _ResetPasswordWithCodePageState();
}

class _ResetPasswordWithCodePageState extends State<ResetPasswordWithCodePage> {
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _loading = false;

  final _authService = AuthService();

  @override
  void dispose() {
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    final p1 = _passCtrl.text;
    final p2 = _pass2Ctrl.text;

    if (p1.isEmpty || p2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifre alanları boş olamaz")),
      );
      return;
    }

    if (p1 != p2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifreler aynı değil")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.resetPasswordWithCode(
        ResetPasswordWithCodeRequest(
          email: widget.email,
          code: widget.code,
          newPassword: p1,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifre sıfırlandı ✅ Giriş yapabilirsin")),
      );

      // İki ekran geri + login'e dönmek için:
      Navigator.popUntil(context, (route) => route.isFirst);

      // Eğer isFirst login değilse, burada login sayfana push edebilirsin:
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Şifre sıfırlanamadı: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Şifre")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Email: ${widget.email}"),
            const SizedBox(height: 16),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Yeni Şifre",
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pass2Ctrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Yeni Şifre (Tekrar)",
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _reset,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Şifreyi Sıfırla"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
