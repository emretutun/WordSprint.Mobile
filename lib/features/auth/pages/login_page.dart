import 'package:flutter/material.dart';
import 'package:wordsprint/features/home/pages/home_page.dart';
import '../models/login_request.dart';
import '../services/auth_service.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  // Modern Input Decorator
  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.indigo),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.indigo, width: 2),
      ),
    );
  }

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.login(LoginRequest(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      ));
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Üst Kısım: Karşılama Alanı
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Colors.blueAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.auto_awesome, size: 80, color: Colors.white),
                  SizedBox(height: 10),
                  Text("WordSprint", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  Text("Hızlı Öğren, Akılda Tut", style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputStyle("E-posta", Icons.email_outlined),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: _inputStyle("Şifre", Icons.lock_outline),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage())),
                      child: const Text("Şifremi Unuttum", style: TextStyle(color: Colors.indigo)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Giriş Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                      ),
                      child: _loading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Giriş Yap", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Kayıt Ol Linki
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Hesabın yok mu?"),
                      TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                        child: const Text("Hemen Kayıt Ol", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                      ),
                    ],
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}