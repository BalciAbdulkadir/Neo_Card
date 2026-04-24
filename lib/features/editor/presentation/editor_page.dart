import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'editor_controller.dart';
import '../../../core/utils/validators.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../core/services/nfc_service.dart';

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

  // Preset Link Controllers
  final _websiteController = TextEditingController();
  final _instagramController = TextEditingController();
  final _xController = TextEditingController();
  final _linkedinController = TextEditingController();

  String? _websiteLinkId;
  String? _instagramLinkId;
  String? _xLinkId;
  String? _linkedinLinkId;

  // Custom link modal controllers
  final _platformController = TextEditingController();
  final _urlController = TextEditingController();

  bool _isInit = false;

  @override
  void dispose() {
    _nameController.dispose();
    _jobController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _instagramController.dispose();
    _xController.dispose();
    _linkedinController.dispose();
    _platformController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _syncControllers(EditorState editorState) {
    if (!_isInit) {
      _nameController.text = editorState.profile.fullName ?? '';
      _jobController.text = editorState.profile.jobTitle ?? '';
      _emailController.text = editorState.profile.email ?? '';

      final phoneData = Validators.parsePhone(
        editorState.profile.phoneNumber ?? '',
      );
      _countryCode = phoneData['countryCode']!;
      _phoneNumber = phoneData['number']!;
      _fullPhoneNumber = editorState.profile.phoneNumber ?? '';

      // Preset Linkleri Eşzamanla (1:N modelinden form alanlarına çıkarma)
      for (var link in editorState.links) {
        final platform = link.platform.toLowerCase();
        if (platform == 'website') {
          _websiteController.text = link.url;
          _websiteLinkId = link.id;
        } else if (platform == 'instagram') {
          _instagramController.text = _extractUsername('instagram', link.url);
          _instagramLinkId = link.id;
        } else if (platform == 'x' || platform == 'twitter') {
          _xController.text = _extractUsername('x', link.url);
          _xLinkId = link.id;
        } else if (platform == 'linkedin') {
          _linkedinController.text = _extractUsername('linkedin', link.url);
          _linkedinLinkId = link.id;
        }
      }

      _isInit = true;
    }
  }

  String _extractUsername(String platform, String url) {
    if (platform == 'instagram' && url.contains('instagram.com/')) {
      return url.split('instagram.com/').last.replaceAll('/', '');
    }
    if (platform == 'x' && url.contains('x.com/')) {
      return url.split('x.com/').last.replaceAll('/', '');
    }
    if (platform == 'linkedin' && url.contains('linkedin.com/in/')) {
      return url.split('linkedin.com/in/').last.replaceAll('/', '');
    }
    return url;
  }

  void _saveProfile() async {
    FocusScope.of(context).unfocus();

    // Temel Profili Kaydet
    ref
        .read(editorControllerProvider.notifier)
        .updateProfile(
          fullName: _nameController.text.trim(),
          jobTitle: _jobController.text.trim(),
          email: _emailController.text.trim(),
          phoneNumber: _fullPhoneNumber,
        );

    // Otomatik Sabit Alanları N:1 yapısıyla eşzamanla
    await _savePresetLink('website', _websiteController.text, _websiteLinkId);
    await _savePresetLink(
      'instagram',
      _instagramController.text,
      _instagramLinkId,
    );
    await _savePresetLink('x', _xController.text, _xLinkId);
    await _savePresetLink(
      'linkedin',
      _linkedinController.text,
      _linkedinLinkId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil başarıyla kaydedildi!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _savePresetLink(
    String platform,
    String rawValue,
    String? linkId,
  ) async {
    final controller = ref.read(editorControllerProvider.notifier);
    if (rawValue.trim().isEmpty) {
      if (linkId != null) {
        // Silinmek isteniyor
        await controller.removeLink(linkId);
      }
      return;
    }
    final formattedUrl = Validators.formatSocialUrl(platform, rawValue);
    await controller.upsertLink(
      id: linkId,
      platform: platform,
      url: formattedUrl,
    );
  }

  void _openCustomLinkModal(BuildContext context) {
    _platformController.clear();
    _urlController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Özel Platform Ekle',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _platformController,
              decoration: InputDecoration(
                labelText: 'Platform (örn: TikTok)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'URL (https://...)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final platform = _platformController.text.trim();
                final urlInput = _urlController.text.trim();
                if (platform.isNotEmpty && urlInput.isNotEmpty) {
                  final formattedUrl = Validators.formatUrl(urlInput);
                  ref
                      .read(editorControllerProvider.notifier)
                      .upsertLink(platform: platform, url: formattedUrl);
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ekle',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startNfcWriteProcess(String uid) {
    final url = 'https://neocard-one.vercel.app/p/$uid';

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.nfc, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 16),
            const Text(
              'NFC Yazma Oturumu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Lütfen Neo Card\'ınızı telefonunuzun arkasına yaklaştırın ve bekleyin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );

    ref
        .read(nfcServiceProvider)
        .writeNdef(url)
        .then((_) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kart başarıyla yazıldı! ✅'),
              backgroundColor: Colors.green,
            ),
          );
        })
        .catchError((error) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: $error'),
              backgroundColor: Colors.redAccent,
            ),
          );
        });
  }

  Widget _buildPresetField(
    String label,
    IconData icon,
    TextEditingController controller,
    Color iconColor,
  ) {
    final platformName = label.toLowerCase();
    String hint = 'Tam URL giriniz';
    if (platformName.contains('instagram') ||
        platformName.contains('x') ||
        platformName.contains('linkedin')) {
      hint = 'Kullanıcı Adı veya URL';
    }
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: iconColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: iconColor.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: iconColor, width: 2.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: iconColor.withOpacity(0.04),
      ),
    );
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
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: editorStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Bir sorun oluştu: $err')),
        data: (editorState) {
          _syncControllers(editorState);

          final customLinks = editorState.links
              .where(
                (l) => ![
                  'website',
                  'instagram',
                  'x',
                  'twitter',
                  'linkedin',
                ].contains(l.platform.toLowerCase()),
              )
              .toList();

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
                        onTap: () => ref
                            .read(editorControllerProvider.notifier)
                            .pickAndUploadAvatar(),
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
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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
                            'Tüm Değişiklikleri Kaydet',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _startNfcWriteProcess(editorState.profile.id!),
                          icon: const Icon(Icons.nfc),
                          label: const Text(
                            'Karta Yaz (NFC)',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            minimumSize: const Size(double.infinity, 54),
                            side: const BorderSide(
                              color: Colors.deepPurple,
                              width: 2,
                            ),
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

                // === SABİT SOSYAL MEDYA LİNKLERİ ===
                Card(
                  elevation: 6,
                  shadowColor: Colors.black.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sosyal Medya Vitrini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPresetField(
                          'Kişisel Web Sitesi',
                          Icons.language,
                          _websiteController,
                          Colors.blueGrey,
                        ),
                        const SizedBox(height: 12),
                        _buildPresetField(
                          'Instagram',
                          Icons.camera_alt,
                          _instagramController,
                          Colors.pinkAccent,
                        ),
                        const SizedBox(height: 12),
                        _buildPresetField(
                          'X (Twitter)',
                          Icons.alternate_email,
                          _xController,
                          Colors.black87,
                        ),
                        const SizedBox(height: 12),
                        _buildPresetField(
                          'LinkedIn',
                          Icons.business,
                          _linkedinController,
                          Colors.blue.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'İpucu: Sadece kullanıcı adınızı yazmanız yeterlidir. Tam URL otomatik oluşturulur.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // === ÖZEL LİNKLER (MÜŞTERİ SEÇİMİ) ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Özel Platformlar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _openCustomLinkModal(context),
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.deepPurple,
                      ),
                      label: const Text(
                        'Yeni Ekle',
                        style: TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (customLinks.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: customLinks.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final link = customLinks[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.deepPurple.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
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
                ],
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
