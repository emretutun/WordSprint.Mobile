import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/verify_reset_code_request.dart';
import 'reset_password_with_code_page.dart';

class VerifyResetCodePage extends StatefulWidget {
  final String email;
  const VerifyResetCodePage({super.key, required this.email});

  @override
  State<VerifyResetCodePage> createState() => _VerifyResetCodePageState();
}

class _VerifyResetCodePageState extends State<VerifyResetCodePage> {
  final _codeCtrl = TextEditingController();
  bool _loading = false;

  final _authService = AuthService();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeCtrl.text.trim();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kod boş olamaz")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.verifyResetCode(
        VerifyResetCodeRequest(email: widget.email, code: code),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordWithCodePage(
            email: widget.email,
            code: code,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kod doğrulanamadı: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kod Doğrulama")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Kod, ${widget.email} adresine gönderildi."),
            const SizedBox(height: 16),
            TextField(
              controller: _codeCtrl,
              decoration: const InputDecoration(
                labelText: "Kod",
                hintText: "Örn: UPrGNQ",
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Doğrula"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
