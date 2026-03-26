import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'editor_controller.dart';
import '../../../core/utils/validators.dart';
import '../../auth/presentation/auth_controller.dart';

class EditorPage extends ConsumerStatefulWidget {
  const EditorPage({super.key});

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  final _nameController = TextEditingController();
  final _jobController = TextEditingController();
  final _emailController = TextEditingController();
  String _phoneNumber = '';
  String _countryCode = 'TR';
  String _fullPhoneNumber = '';
  
  final _platformController = TextEditingController();
  final _urlController = TextEditingController();

  bool _isInit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _jobController.dispose();
    _emailController.dispose();
    _platformController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _syncControllers(EditorState editorState) {
    if (!_isInit) {
      _nameController.text = editorState.profile.fullName ?? '';
      _jobController.text = editorState.profile.jobTitle ?? '';
      _emailController.text = editorState.profile.email ?? '';
      
      final phoneData = Validators.parsePhone(editorState.profile.phoneNumber ?? '');
      _countryCode = phoneData['countryCode']!;
      _phoneNumber = phoneData['number']!;
      _fullPhoneNumber = editorState.profile.phoneNumber ?? '';

      _isInit = true;
    }
  }

  void _saveProfile() {
    FocusScope.of(context).unfocus();
    ref.read(editorControllerProvider.notifier).updateProfile(
      fullName: _nameController.text.trim(),
      jobTitle: _jobController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _fullPhoneNumber,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil başarıyla kaydedildi!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addLink() {
    final platform = _platformController.text.trim();
    final urlInput = _urlController.text.trim();
    if (platform.isEmpty || urlInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Platform ve Link boş bırakılamaz.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Valiasyon - URL kontrolü
    final formattedUrl = Validators.formatUrl(urlInput);

    FocusScope.of(context).unfocus();
    ref.read(editorControllerProvider.notifier).addLink(platform, formattedUrl);

    _platformController.clear();
    _urlController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final editorStateAsync = ref.watch(editorControllerProvider);

    ref.listen<AsyncValue>(editorControllerProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${state.error}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.surfaceVariant.withOpacity(0.3),
      appBar: AppBar(
        title: const Text(
          'Profilini Düzenle',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: editorStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Bir sorun oluştu: $err')),
        data: (editorState) {
          _syncControllers(editorState);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // === AVATAR DÜZENLEME ===
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.deepPurple.shade100,
                        backgroundImage: editorState.profile.avatarUrl != null
                            ? NetworkImage(editorState.profile.avatarUrl!)
                            : null,
                        child: editorState.profile.avatarUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.deepPurple,
                              )
                            : null,
                      ),
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(editorControllerProvider.notifier)
                              .pickAndUploadAvatar();
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // === PROFIL BILGILERI FORMU ===
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Temel Bilgiler',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Ad Soyad',
                            prefixIcon: const Icon(Icons.badge),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _jobController,
                          decoration: InputDecoration(
                            labelText: 'Ünvan',
                            prefixIcon: const Icon(Icons.work),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'İletişim E-posta',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        IntlPhoneField(
                          decoration: InputDecoration(
                            labelText: 'Telefon Numarası',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          initialCountryCode: _countryCode,
                          initialValue: _phoneNumber,
                          onChanged: (phone) {
                            _fullPhoneNumber = phone.completeNumber;
                          },
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _saveProfile,
                          icon: const Icon(Icons.save_rounded),
                          label: const Text(
                            'Değişiklikleri Kaydet',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // === DİNAMİK LİNKLER FORMU ===
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dijital Linklerim',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _platformController,
                                decoration: InputDecoration(
                                  labelText: 'Platform',
                                  hintText: 'Instagram',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                controller: _urlController,
                                decoration: InputDecoration(
                                  labelText: 'URL veya Kullanıcı Adı',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _addLink,
                          icon: const Icon(Icons.add_link),
                          label: const Text('Yeni Link Ekle'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondaryContainer,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // === EKLENMİŞ LİNKLERİN LİSTESİ ===
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: editorState.links.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final link = editorState.links[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple.shade50,
                          child: const Icon(
                            Icons.link,
                            color: Colors.deepPurple,
                          ),
                        ),
                        title: Text(
                          link.platform.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          link.url,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            if (link.id != null)
                              ref
                                  .read(editorControllerProvider.notifier)
                                  .removeLink(link.id!);
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
