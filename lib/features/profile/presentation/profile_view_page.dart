import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_controller.dart';
import '../../editor/data/user_profile_model.dart';

class ProfileViewPage extends ConsumerWidget {
  final String uid;

  const ProfileViewPage({super.key, required this.uid});

  void _downloadVCard(BuildContext context, UserProfileModel profile) {
    // VCard v3.0 standart çıktısı
    // ignore: unused_local_variable
    final vcard =
        '''BEGIN:VCARD
VERSION:3.0
N:;${profile.fullName ?? ''};;;
FN:${profile.fullName ?? ''}
TITLE:${profile.jobTitle ?? ''}
EMAIL;TYPE=INTERNET:${profile.email ?? ''}
TEL;TYPE=CELL:${profile.phoneNumber ?? ''}
END:VCARD''';

    // Projenin bir sonraki aşamasında bu stringi vcf dosyası olarak mobil
    // klasör sistemine yazıp paylaşacağız. Şu anlık stub olarak duruyor.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'VCard indirme özelliği (yazma erişimleri nedeniyle) yerel entegrasyon sonrası devreye girecektir.',
        ),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Açılamadı: $url');
    }
  }

  void _showQrCode(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil QR Kodum', textAlign: TextAlign.center),
        content: SizedBox(
          width: 250,
          height: 250,
          child: QrImageView(
            data: 'https://neocard-one.vercel.app/p/$uid',
            version: QrVersions.auto,
            size: 250.0,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileControllerProvider(uid));

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Profil Yüklenemedi:\n$err', textAlign: TextAlign.center),
        ),
        data: (state) {
          final profile = state.profile;

          Color themeColor = Colors.deepPurple;
          if (profile.themeColor != null && profile.themeColor!.length == 7) {
            final hex = profile.themeColor!.replaceAll('#', '0xFF');
            themeColor = Color(int.parse(hex));
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 280.0,
                floating: false,
                pinned: true,
                backgroundColor: themeColor,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    profile.fullName ?? 'İsimsiz Kart',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                    ),
                  ),
                  background: profile.avatarUrl != null
                      ? Image.network(
                          profile.avatarUrl!,
                          fit: BoxFit.cover,
                          color: Colors.black45,
                          colorBlendMode: BlendMode.darken,
                        )
                      : Container(
                          color: themeColor,
                          child: const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white54,
                          ),
                        ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.qr_code, color: Colors.white),
                    onPressed: () => _showQrCode(context),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 32.0,
                  ),
                  child: Column(
                    children: [
                      Text(
                        profile.jobTitle ?? '',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Hızlı Aksiyonlar (Email & Telefon)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (profile.phoneNumber != null &&
                              profile.phoneNumber!.isNotEmpty)
                            InkWell(
                              onTap: () =>
                                  _launchUrl('tel:${profile.phoneNumber}'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: themeColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.phone,
                                  size: 30,
                                  color: themeColor,
                                ),
                              ),
                            ),
                          if (profile.email != null &&
                              profile.email!.isNotEmpty)
                            InkWell(
                              onTap: () =>
                                  _launchUrl('mailto:${profile.email}'),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: themeColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.email,
                                  size: 30,
                                  color: themeColor,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () => _downloadVCard(context, profile),
                        icon: const Icon(Icons.person_add),
                        label: const Text(
                          'Rehbere Ekle',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),
                      // Dinamik Linkler
                      if (state.links.isNotEmpty) ...[
                        const Text(
                          'Dijital İletişim Ağı',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...state.links.map(
                          (link) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () => _launchUrl(link.url),
                              borderRadius: BorderRadius.circular(16),
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 4,
                                  ),
                                  leading: Icon(
                                    Icons.link,
                                    color: themeColor,
                                    size: 28,
                                  ),
                                  title: Text(
                                    link.platform.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
