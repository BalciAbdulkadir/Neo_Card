import 'package:flutter/material.dart';
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
    if (mounted) setState(() => _isLoading = false);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Profil Güncellendi!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      // Linki Oluştur: https://neocard.app/p/UID
      // şimdilik test domaini
      String link = "https://neocard.app/p/${widget.uid}";

      //yaz
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
      _showError("NFC Yazma Hatası: $e");
    }
  }

  void _showError(String mesaj) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hata"),
        content: Text(mesaj),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tamam"),
          ),
        ],
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
                  _buildTextField(_nameController, "Ad Soyad", Icons.person),
                  const SizedBox(height: 15),
                  _buildTextField(_titleController, "Unvan", Icons.work),
                  const SizedBox(height: 15),
                  _buildTextField(_emailController, "E-Posta", Icons.email),
                  const SizedBox(height: 15),
                  _buildTextField(
                    _instagramController,
                    "Instagram",
                    Icons.camera_alt,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(_linkedinController, "LinkedIn", Icons.link),
                  const SizedBox(height: 30),

                  // KAYDET BUTONU
                  ElevatedButton.icon(
                    onPressed: _saveData,
                    icon: const Icon(Icons.save),
                    label: const Text("BİLGİLERİ KAYDET"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.grey[800], // Rengi değiştirdim karışmasın
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Karta Yaz Butonu
                  ElevatedButton.icon(
                    onPressed: _writeToNfc,
                    icon: const Icon(Icons.nfc),
                    label: const Text("NFC KARTA YAZ"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 5,
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
