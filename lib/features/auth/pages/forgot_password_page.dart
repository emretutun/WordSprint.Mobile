import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/forgot_password_request.dart';
import 'reset_password_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  // Bellek sızıntısını önlemek için controller'ı temizliyoruz
  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.indigo),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 100, color: Colors.indigo),
            const SizedBox(height: 24),
            const Text(
              "Şifreni mi Unuttun?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "E-posta adresini gir, sana şifreni sıfırlaman için bir bağlantı gönderelim.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: "E-posta",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleForgotPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Kod Gönder",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mantığı ayrı bir metoda almak kodu daha okunabilir kılar
  Future<void> _handleForgotPassword() async {
    setState(() => _loading = true);

    try {
      await _auth.forgotPassword(
        ForgotPasswordRequest(email: _emailCtrl.text.trim()),
      );

      // ASYNC GAP KONTROLÜ: Widget ağaçtan ayrıldıysa navigasyon yapma
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
      );
    } catch (e) {
      // ASYNC GAP KONTROLÜ: Hata mesajı göstermeden önce de kontrol şart
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      // Widget hala ekrandaysa loading'i kapat
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}