import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/user_repository.dart';
import '../data/user_profile_model.dart';
import '../data/user_link_model.dart';
import '../../../core/services/image_picker_service.dart';

class EditorState {
  final UserProfileModel profile;
  final List<UserLinkModel> links;

  EditorState({required this.profile, required this.links});

  EditorState copyWith({
    UserProfileModel? profile,
    List<UserLinkModel>? links,
  }) {
    return EditorState(
      profile: profile ?? this.profile,
      links: links ?? this.links,
    );
  }
}

class EditorController extends AsyncNotifier<EditorState> {
  late UserRepository _repo;
  late String _userId;

  @override
  FutureOr<EditorState> build() async {
    _repo = ref.watch(userRepositoryProvider);
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('Kullanıcı oturumu bulunamadı.');
    }
    _userId = user.id;

    return _fetchData();
  }

  Future<EditorState> _fetchData() async {
    var profile = await _repo.getUserProfile(_userId);
    // Initialize empty profile conceptually if totally fresh
    profile ??= UserProfileModel(
        id: _userId, 
        createdAt: DateTime.now()
    );

    final links = await _repo.getUserLinks(_userId);

    return EditorState(profile: profile, links: links);
  }

  Future<void> updateProfile({
    String? fullName,
    String? jobTitle,
    String? email,
    String? phoneNumber,
  }) async {
    if (state.value == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedProfile = state.value!.profile.copyWith(
        fullName: fullName,
        jobTitle: jobTitle,
        email: email,
        phoneNumber: phoneNumber,
      );
      await _repo.upsertUserProfile(updatedProfile);
      return _fetchData();
    });
  }

  Future<void> pickAndUploadAvatar() async {
    if (state.value == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final imageService = ref.read(imagePickerServiceProvider);
      final String? avatarUrl = await imageService.pickAndUploadImage(_userId);
      
      if (avatarUrl != null) {
        final updatedProfile = state.value!.profile.copyWith(avatarUrl: avatarUrl);
        await _repo.upsertUserProfile(updatedProfile);
      }
      return _fetchData();
    });
  }

  Future<void> upsertLink({String? id, required String platform, required String url}) async {
    if (state.value == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentLinks = state.value!.links;
      int order = currentLinks.length;
      
      if (id != null) {
        try {
          order = currentLinks.firstWhere((l) => l.id == id).orderIndex;
        } catch (_) {}
      }

      final newLink = UserLinkModel(
        id: id,
        profileId: _userId,
        platform: platform,
        url: url,
        orderIndex: order,
      );
      await _repo.upsertUserLink(newLink);
      return _fetchData();
    });
  }

  Future<void> removeLink(String linkId) async {
    if (state.value == null) return;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repo.deleteUserLink(linkId);
      return _fetchData();
    });
  }
}

final editorControllerProvider = AsyncNotifierProvider<EditorController, EditorState>(() {
  return EditorController();
});
