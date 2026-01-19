import 'dart:convert';
import 'dart:io';
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
  // Servisler
  final DatabaseService _dbService = DatabaseService();
  final NfcService _nfcService = NfcService();
  final ImagePicker _picker = ImagePicker();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  // Sosyal Medya
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();

  File? _selectedImage;
  String? _currentPhotoData; //Görsel için BASE64 kullanıyoruz mecbur
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

        // Sosyal Medya
        _instagramController.text = user.socialLinks['instagram'] ?? '';
        _twitterController.text = user.socialLinks['twitter'] ?? '';
        _linkedinController.text = user.socialLinks['linkedin'] ?? '';
      });
    }
    if (mounted) setState(() => _isLoading = false);
  }

  // FOTOĞRAF SEÇME VE KÜÇÜLTME
  void _pickPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400, // Resmi küçültüyoz database şişmesin
        imageQuality: 60,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Resim seçme hatası: $e");
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

      // base64'e çevir
      if (_selectedImage != null) {
        List<int> imageBytes = await _selectedImage!.readAsBytes();
        photoData = base64Encode(imageBytes);
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
            content: Text("✅ Bilgiler ve Resim Kaydedildi!"),
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

  // NFC
  void _writeToNfc() async {
    bool isAvailable = await _nfcService.checkAvailability();
    if (!isAvailable) {
      _showError("Cihazınızda NFC yok veya kapalı!");
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("⏳ Kartı telefonun arkasına yaklaştırın..."),
      ),
    );

    try {
      String link = "https://neo-card-app.web.app/p/${widget.uid}";
      await _nfcService.writeNfc(link, lock: false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Kart Başarıyla Yazıldı!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError("NFC Hatası: $e");
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

    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (_currentPhotoData != null && _currentPhotoData!.isNotEmpty) {
      if (_currentPhotoData!.startsWith('http')) {
        imageProvider = NetworkImage(_currentPhotoData!);
      } else {
        try {
          imageProvider = MemoryImage(base64Decode(_currentPhotoData!));
          // ignore: empty_catches
        } catch (e) {}
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kartvizit Düzenle"),
        backgroundColor: Colors.deepPurple[100],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: imageProvider,
                        child: imageProvider == null
                            ? const Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "Fotoğrafı Değiştirmek İçin Dokun",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle("Kişisel Bilgiler"),
                  _buildTextField(_nameController, "Ad Soyad", Icons.person),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _titleController,
                    "Unvan / Meslek",
                    Icons.work,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _phoneController,
                    "Telefon Numarası",
                    Icons.phone,
                    type: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _emailController,
                    "E-Posta Adresi",
                    Icons.email,
                    type: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _websiteController,
                    "Kişisel Web Sitesi (Opsiyonel)",
                    Icons.language,
                  ),

                  const SizedBox(height: 20),

                  _buildSectionTitle("Sosyal Medya"),
                  _buildTextField(
                    _instagramController,
                    "Instagram Kullanıcı Adı",
                    Icons.camera_alt,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _twitterController,
                    "X (Twitter) Kullanıcı Adı",
                    Icons.alternate_email,
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(
                    _linkedinController,
                    "LinkedIn Profil Linki",
                    Icons.business,
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: _saveData,
                    icon: const Icon(Icons.save),
                    label: const Text("KAYDET"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _writeToNfc,
                    icon: const Icon(Icons.nfc),
                    label: const Text("NFC KARTA YAZ"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ),
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
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 15,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.deepPurple,
        ),
      ),
    );
  }
}
