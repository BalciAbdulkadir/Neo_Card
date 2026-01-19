import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/nfc_service.dart';

class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _dbService = DatabaseService();
  final NfcService _nfcService = NfcService();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _currentPhotoData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);
    UserModel? user = await _dbService.getUser(widget.uid);
    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _titleController.text = user.jobTitle;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber;
        _websiteController.text = user.website;
        _currentPhotoData = user.profilePhotoUrl;
        _instagramController.text = user.socialLinks['instagram'] ?? '';
        _twitterController.text = user.socialLinks['twitter'] ?? '';
        _linkedinController.text = user.socialLinks['linkedin'] ?? '';
      });
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _pickPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        imageQuality: 50,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint("Resim hatası: $e");
    }
  }

  void _saveData() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ad Soyad boş olamaz!")));
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      String photoData = _currentPhotoData ?? "";
      if (_selectedImageBytes != null) {
        photoData = base64Encode(_selectedImageBytes!);
      }

      UserModel newUser = UserModel(
        uid: widget.uid,
        name: _nameController.text.trim(),
        jobTitle: _titleController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        profilePhotoUrl: photoData,
        website: _websiteController.text.trim(),
        socialLinks: {
          'instagram': _instagramController.text.trim(),
          'twitter': _twitterController.text.trim(),
          'linkedin': _linkedinController.text.trim(),
        },
      );

      await _dbService.saveUser(newUser);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Profil Güncellendi!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _writeToNfc() async {
    bool isAvailable = await _nfcService.checkAvailability();
    if (!isAvailable) {
      _showError("NFC kapalı!");
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("⏳ Kartı yaklaştırın...")));
    try {
      String link = "https://neo-card-app.web.app/p/${widget.uid}";
      await _nfcService.writeNfc(link, lock: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Kart Yazıldı!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError("Hata: $e");
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_selectedImageBytes != null) {
      imageProvider = MemoryImage(_selectedImageBytes!);
    } else if (_currentPhotoData != null && _currentPhotoData!.isNotEmpty) {
      if (_currentPhotoData!.startsWith('http')) {
        imageProvider = NetworkImage(_currentPhotoData!);
      } else {
        try {
          imageProvider = MemoryImage(base64Decode(_currentPhotoData!));
        } catch (_) {}
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "NeoCard Editör",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // PROFİL FOTOĞRAFI ALANI
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.deepPurple,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: imageProvider,
                            child: imageProvider == null
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickPhoto,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.deepPurple,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // KİŞİSEL BİLGİLER KARTI
                  _buildCardContainer(
                    title: "Kişisel Bilgiler",
                    icon: Icons.person_outline,
                    children: [
                      _buildTextField(
                        _nameController,
                        "Ad Soyad",
                        Icons.person,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        _titleController,
                        "Unvan / Meslek",
                        Icons.work_outline,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        _phoneController,
                        "Telefon",
                        Icons.phone,
                        type: TextInputType.phone,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        _emailController,
                        "E-Posta",
                        Icons.email_outlined,
                        type: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        _websiteController,
                        "Web Sitesi",
                        Icons.language,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  //SOSYAL MEDYA KARTI
                  _buildCardContainer(
                    title: "Sosyal Medya",
                    icon: Icons.share,
                    children: [
                      _buildTextField(
                        _instagramController,
                        "Instagram Kullanıcı Adı",
                        Icons.camera_alt_outlined,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        _twitterController,
                        "X (Twitter) Kullanıcı Adı",
                        Icons.alternate_email,
                      ),
                      const SizedBox(height: 15),
                      _buildTextField(
                        _linkedinController,
                        "LinkedIn Profil Linki",
                        Icons.business_center_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  //BUTONLAR
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _saveData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "DEĞİŞİKLİKLERİ KAYDET",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: _writeToNfc,
                      icon: const Icon(Icons.nfc),
                      label: const Text("NFC KARTA YAZ"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.black87, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildCardContainer({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.deepPurple),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
