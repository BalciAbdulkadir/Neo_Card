// Dosya: lib/pages/profile_view_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class ProfileViewPage extends StatefulWidget {
  final String uid; // URL'den gelen ID
  const ProfileViewPage({super.key, required this.uid});

  @override
  State<ProfileViewPage> createState() => _ProfileViewPageState();
}

class _ProfileViewPageState extends State<ProfileViewPage> {
  final DatabaseService _dbService = DatabaseService();
  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  //  Kullanıcı verisini çek
  void _fetchUser() async {
    UserModel? user = await _dbService.getUser(widget.uid);

    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
        if (user == null) {
          _errorMessage = "Kullanıcı bulunamadı veya profil gizli.";
        }
      });
    }
  }

  // Linki tarayıcıda aç
  Future<void> _launchLink(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (!await launchUrl(uri)) {
      debugPrint("Link açılamadı: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Yükleniyor Ekranı
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != null || _user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 10),
              Text(_errorMessage ?? "Hata"),
            ],
          ),
        ),
      );
    }

    // Kartvizit
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profil Fotosu
              const CircleAvatar(
                radius: 50,
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),

              // İsim
              Text(
                _user!.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              // Unvan
              Text(
                _user!.jobTitle,
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // SOSYAL MEDYA BUTONLARI
              if (_user!.links['instagram']?.isNotEmpty == true)
                _buildSocialButton(
                  "Instagram",
                  Colors.pink,
                  Icons.camera_alt,
                  "https://instagram.com/${_user!.links['instagram']}",
                ),

              const SizedBox(height: 10),

              if (_user!.links['linkedin']?.isNotEmpty == true)
                _buildSocialButton(
                  "LinkedIn",
                  Colors.blue[800]!,
                  Icons.business,
                  _user!.links['linkedin'],
                ),

              const SizedBox(height: 10),

              // Email
              if (_user!.email.isNotEmpty)
                _buildSocialButton(
                  "E-Posta Gönder",
                  Colors.redAccent,
                  Icons.email,
                  "mailto:${_user!.email}",
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    String text,
    Color color,
    IconData icon,
    String url,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () => _launchLink(url),
      ),
    );
  }
}
