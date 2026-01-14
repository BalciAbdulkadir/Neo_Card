// File: lib/pages/home_page.dart

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class HomePage extends StatefulWidget {
  final String uid; // id ye göre sayfa açılıyor
  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _dbService = DatabaseService();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Verileri firebase'den çekme
  void _loadData() async {
    setState(() => _isLoading = true);

    UserModel? user = await _dbService.getUser(widget.uid);

    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _titleController.text = user.jobTitle;
        _emailController.text = user.email;
        _instagramController.text = user.links['instagram'] ?? '';
        _linkedinController.text = user.links['linkedin'] ?? '';
      });
    }

    setState(() => _isLoading = false);
  }

  // kaydetme
  void _saveData() async {
    // Basic validation
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Ad Soyad boş olamaz!")));
      return;
    }

    setState(() => _isLoading = true);

    UserModel newUser = UserModel(
      uid: widget.uid,
      name: _nameController.text.trim(),
      jobTitle: _titleController.text.trim(),
      email: _emailController.text.trim(),
      profilePhoto: "",
      links: {
        'instagram': _instagramController.text.trim(),
        'linkedin': _linkedinController.text.trim(),
      },
    );

    await _dbService.saveUser(newUser);

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profil başarıyla güncellendi! ✅"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Düzenle"),
        backgroundColor: Colors.deepPurple[100],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Kartvizit Bilgilerin",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "UID: ${widget.uid}",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 20),

                  // NAME
                  _buildTextField(_nameController, "Ad Soyad", Icons.person),
                  const SizedBox(height: 15),

                  // TITLE
                  _buildTextField(
                    _titleController,
                    "Unvan (Örn: CEO)",
                    Icons.work,
                  ),
                  const SizedBox(height: 15),

                  // EMAIL
                  _buildTextField(_emailController, "E-Posta", Icons.email),
                  const SizedBox(height: 30),

                  const Text(
                    "Sosyal Medya",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // INSTAGRAM
                  _buildTextField(
                    _instagramController,
                    "Instagram Kullanıcı Adı",
                    Icons.camera_alt,
                  ),
                  const SizedBox(height: 15),

                  // LINKEDIN
                  _buildTextField(
                    _linkedinController,
                    "LinkedIn Profili (URL)",
                    Icons.link,
                  ),
                  const SizedBox(height: 30),

                  // SAVE BUTTON
                  ElevatedButton.icon(
                    onPressed: _saveData,
                    icon: const Icon(Icons.save),
                    label: const Text("BİLGİLERİ KAYDET"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
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
    IconData icon,
  ) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }
}
