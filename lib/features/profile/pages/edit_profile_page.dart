import 'package:flutter/material.dart';
import '../models/profile_response.dart';
import '../models/update_profile_request.dart';
import '../services/profile_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  final _picker = ImagePicker();
  File? _selectedPhoto;
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

  // Modern Input Decorator (Tutarlılık için)
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

  Future<void> _pickAndUploadPhoto() async {
    try {
      final xfile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (xfile == null) return;

      setState(() {
        _selectedPhoto = File(xfile.path);
        _loading = true;
      });

      // Fotoğraf seçildiği anda yükleme işlemini başlatalım (UX için daha akıcı)
      await _service.uploadPhoto(_selectedPhoto!);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil fotoğrafı güncellendi ✅")));
    } catch (e) {
      setState(() => _error = "Fotoğraf yüklenemedi: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() { _loading = true; _error = null; });
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
      Navigator.pop(context, true);
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
      appBar: AppBar(
        title: const Text("Profili Düzenle", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _loading && _selectedPhoto != null 
          ? const Center(child: CircularProgressIndicator()) 
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profil Fotoğrafı Düzenleme Alanı
                  _buildPhotoEditor(),
                  const SizedBox(height: 32),
                  
                  // Form Alanları
                  TextField(controller: _firstCtrl, decoration: _inputStyle("Ad", Icons.person_outline)),
                  const SizedBox(height: 16),
                  TextField(controller: _lastCtrl, decoration: _inputStyle("Soyad", Icons.person_outline)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _goalCtrl, 
                    keyboardType: TextInputType.number, 
                    decoration: _inputStyle("Günlük Kelime Hedefi", Icons.flag_outlined)
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: _levelCtrl, decoration: _inputStyle("Tahmini Seviye", Icons.trending_up)),
                  
                  const SizedBox(height: 32),
                  
                  // Kaydet Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _loading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("Değişiklikleri Kaydet", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  ]
                ],
              ),
            ),
    );
  }

  Widget _buildPhotoEditor() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.indigo.shade50,
          backgroundImage: _selectedPhoto != null 
              ? FileImage(_selectedPhoto!) 
              : (widget.initial.photoUrl.isNotEmpty ? NetworkImage(widget.initial.photoUrl) as ImageProvider : null),
          child: (_selectedPhoto == null && widget.initial.photoUrl.isEmpty)
              ? const Icon(Icons.person, size: 60, color: Colors.indigo)
              : null,
        ),
        InkWell(
          onTap: _pickAndUploadPhoto,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.indigo, shape: BoxShape.circle),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}