import 'package:flutter/material.dart';
import '../models/register_request.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  bool _loading = false;
  String? _error; 

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.indigo),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.indigo, width: 2)),
    );
  }

  Future<void> _register() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.register(RegisterRequest(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        firstName: _firstCtrl.text.trim().isEmpty ? null : _firstCtrl.text.trim(),
        lastName: _lastCtrl.text.trim().isEmpty ? null : _lastCtrl.text.trim(),
      ));

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kayıt Başarılı ✅ Lütfen e-postanı onayla."))
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigo, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.indigo,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50)),
              ),
              child: const Column(
                children: [
                  Text("Yeni Hesap Oluştur", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Kelimelerin dünyasına katıl!", style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  
                  TextField(controller: _firstCtrl, decoration: _inputStyle("Ad", Icons.person_outline)),
                  const SizedBox(height: 16),
                  TextField(controller: _lastCtrl, decoration: _inputStyle("Soyad", Icons.person_outline)),
                  const SizedBox(height: 16),
                  TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: _inputStyle("E-posta", Icons.email_outlined)),
                  const SizedBox(height: 16),
                  TextField(controller: _passCtrl, obscureText: true, decoration: _inputStyle("Şifre", Icons.lock_outline)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _loading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("Kayıt Ol", style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}