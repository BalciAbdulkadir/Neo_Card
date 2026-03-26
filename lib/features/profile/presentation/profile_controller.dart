import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/profile_read_repository.dart';
import '../../editor/data/user_profile_model.dart';
import '../../editor/data/user_link_model.dart';

class ProfileState {
  final UserProfileModel profile;
  final List<UserLinkModel> links;

  ProfileState({required this.profile, required this.links});
}

final profileControllerProvider = FutureProvider.autoDispose.family<ProfileState, String>((ref, uid) async {
  final repo = ref.watch(profileReadRepositoryProvider);
  
  // Görüntülemeyi asenkron olarak arka planda arttır
  repo.incrementViewCount(uid);

  final profile = await repo.getProfile(uid);
  if (profile == null) throw Exception('Aradığınız profile ulaşılamadı. Hesap silinmiş veya hatalı link.');

  final links = await repo.getLinks(uid);

  return ProfileState(profile: profile, links: links);
});
