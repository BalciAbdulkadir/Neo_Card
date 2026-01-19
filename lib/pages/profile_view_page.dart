import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class ProfileViewPage extends StatefulWidget {
  final String uid;
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

  void _fetchUser() async {
    UserModel? user = await _dbService.getUser(widget.uid);
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
        if (user == null) {
          _errorMessage = "Profil bulunamadı.";
        }
      });
    }
  }

  // link açıcı
  Future<void> _launchLink(String url) async {
    if (url.isEmpty) return;
    final Uri uri = Uri.parse(
      url.startsWith('http') ||
              url.startsWith('tel') ||
              url.startsWith('mailto')
          ? url
          : 'https://$url',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Link hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_user == null)
      return Scaffold(body: Center(child: Text(_errorMessage ?? "Hata")));

    ImageProvider? profileImage;
    if (_user!.profilePhotoUrl.isNotEmpty) {
      if (_user!.profilePhotoUrl.startsWith('http')) {
        // Eski kayıtlar bozulmasın
        profileImage = NetworkImage(_user!.profilePhotoUrl);
      } else {
        // Base64
        try {
          profileImage = MemoryImage(base64Decode(_user!.profilePhotoUrl));
          // ignore: empty_catches
        } catch (e) {}
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PROFİL FOTOĞRAFI
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.deepPurple,
                  backgroundImage: profileImage,
                  child: profileImage == null
                      ? const Icon(Icons.person, size: 60, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 20),

                // İSİM VE UNVAN
                Text(
                  _user!.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _user!.jobTitle,
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // İLETİŞİM BUTONLARI
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_user!.phoneNumber.isNotEmpty)
                      _buildMiniButton(
                        Icons.phone,
                        Colors.green,
                        "tel:${_user!.phoneNumber}",
                      ),
                    const SizedBox(width: 15),
                    if (_user!.email.isNotEmpty)
                      _buildMiniButton(
                        Icons.email,
                        Colors.redAccent,
                        "mailto:${_user!.email}",
                      ),
                    const SizedBox(width: 15),
                    if (_user!.website.isNotEmpty)
                      _buildMiniButton(
                        Icons.language,
                        Colors.blueGrey,
                        _user!.website,
                      ),
                  ],
                ),
                const SizedBox(height: 30),

                // SOSYAL MEDYA LİSTESİ
                if (_user!.socialLinks['instagram']?.isNotEmpty == true)
                  _buildSocialButton(
                    "Instagram",
                    Colors.purple,
                    Icons.camera_alt,
                    "https://instagram.com/${_user!.socialLinks['instagram']}",
                  ),

                const SizedBox(height: 10),

                if (_user!.socialLinks['twitter']?.isNotEmpty == true)
                  _buildSocialButton(
                    "X (Twitter)",
                    Colors.black,
                    Icons.alternate_email,
                    "https://x.com/${_user!.socialLinks['twitter']}",
                  ),

                const SizedBox(height: 10),

                if (_user!.socialLinks['linkedin']?.isNotEmpty == true)
                  _buildSocialButton(
                    "LinkedIn",
                    Colors.blue[800]!,
                    Icons.business,
                    _user!.socialLinks['linkedin'],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniButton(IconData icon, Color color, String url) {
    return InkWell(
      onTap: () => _launchLink(url),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: 28),
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
        label: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        onPressed: () => _launchLink(url),
      ),
    );
  }
}
