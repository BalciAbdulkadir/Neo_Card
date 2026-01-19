import 'dart:convert';
import 'dart:ui';
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
      });
    }
  }

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
      return const Scaffold(body: Center(child: Text("Profil Bulunamadı")));

    // FOTOĞRAF ÇÖZÜCÜ
    ImageProvider? profileImage;
    if (_user!.profilePhotoUrl.isNotEmpty) {
      if (_user!.profilePhotoUrl.startsWith('http')) {
        profileImage = NetworkImage(_user!.profilePhotoUrl);
      } else {
        try {
          profileImage = MemoryImage(base64Decode(_user!.profilePhotoUrl));
        } catch (_) {}
      }
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E0249), Color(0xFF570A57), Color(0xFFA91079)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //FOTOĞRAF
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              image: profileImage != null
                                  ? DecorationImage(
                                      image: profileImage,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: profileImage == null
                                ? const Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 70,
                                      color: Colors.white70,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // İSİM
                      Text(
                        _user!.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _user!.jobTitle.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 20),

                      // İLETİŞİM BUTONLARI
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_user!.phoneNumber.isNotEmpty)
                            _buildGlassIconButton(
                              Icons.phone,
                              Colors.greenAccent,
                              "tel:${_user!.phoneNumber}",
                            ),
                          if (_user!.email.isNotEmpty)
                            _buildGlassIconButton(
                              Icons.email,
                              Colors.redAccent,
                              "mailto:${_user!.email}",
                            ),
                          if (_user!.website.isNotEmpty)
                            _buildGlassIconButton(
                              Icons.language,
                              Colors.blueAccent,
                              _user!.website,
                            ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // SOSYAL MEDYA BUTONLARI
                      Column(
                        children: [
                          if (_user!.socialLinks['instagram']?.isNotEmpty ==
                              true)
                            _buildSocialButton(
                              "Instagram",
                              Icons.camera_alt,
                              "https://instagram.com/${_user!.socialLinks['instagram']}",
                            ),
                          if (_user!.socialLinks['twitter']?.isNotEmpty == true)
                            _buildSocialButton(
                              "X (Twitter)",
                              Icons.alternate_email,
                              "https://x.com/${_user!.socialLinks['twitter']}",
                            ),
                          if (_user!.socialLinks['linkedin']?.isNotEmpty ==
                              true)
                            _buildSocialButton(
                              "LinkedIn",
                              Icons.business,
                              _user!.socialLinks['linkedin']!,
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      Text(
                        "NeoCard®",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassIconButton(IconData icon, Color color, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () => _launchLink(url),
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String text, IconData icon, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _launchLink(url),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(width: 15),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
