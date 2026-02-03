import 'package:flutter/material.dart';
import '../models/profile_response.dart';
import '../services/profile_service.dart';
import 'edit_profile_page.dart';
import '../../auth/pages/change_password_page.dart';

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
    setState(() { _loading = true; _error = null; });
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profil", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.indigo,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _profile == null
                  ? const Center(child: Text("Profil verisi bulunamadı."))
                  : ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        // 1. Header (Profil Fotoğrafı ve İsim)
                        _buildHeader(),
                        
                        // 2. Bilgi Kartları
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("HESAP BİLGİLERİ", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                              const SizedBox(height: 16),
                              _infoTile(Icons.email_outlined, "E-posta", _profile!.email),
                              _infoTile(Icons.flag_outlined, "Günlük Hedef", "${_profile!.dailyWordGoal} Kelime"),
                              _infoTile(Icons.trending_up, "Tahmini Seviye", _profile!.estimatedLevel ?? "Belirlenmedi"),
                              
                              const SizedBox(height: 32),
                              
                              const Text("AYARLAR", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                              const SizedBox(height: 16),
                              
                              // Aksiyon Butonları (Tile yapısında)
                              _actionTile(
                                Icons.edit_outlined, 
                                "Profili Düzenle", 
                                "İsim, fotoğraf ve hedeflerini güncelle",
                                () async {
                                  final updated = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(builder: (_) => EditProfilePage(initial: _profile!)),
                                  );
                                  if (updated == true) _load();
                                }
                              ),
                              _actionTile(
                                Icons.lock_outline, 
                                "Şifre Değiştir", 
                                "Hesap güvenliğini sağlamak için şifreni yenile",
                                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordPage()))
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildHeader() {
    final fullName = "${_profile!.firstName ?? ""} ${_profile!.lastName ?? ""}".trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 40, top: 20),
      decoration: const BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 52,
              backgroundImage: _profile!.photoUrl.isNotEmpty ? NetworkImage(_profile!.photoUrl) : null,
              child: _profile!.photoUrl.isEmpty ? const Icon(Icons.person, size: 50) : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName.isEmpty ? "Kelime Sprintçisi" : fullName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            "@${_profile!.email.split('@')[0]}",
            style: TextStyle(fontSize: 14, color: Colors.white.withValues()),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.indigo, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: Colors.indigo),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text("Hata: $_error"),
          ElevatedButton(onPressed: _load, child: const Text("Tekrar Dene")),
        ],
      ),
    );
  }
}