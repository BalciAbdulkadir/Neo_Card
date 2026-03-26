import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_profile_model.dart';
import 'user_link_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(Supabase.instance.client);
});

class UserRepository {
  final SupabaseClient _client;

  UserRepository(this._client);

  /// PROFİL VERİLERİ (profiles)
  
  Future<UserProfileModel?> getUserProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfileModel.fromMap(response);
  }

  Future<void> upsertUserProfile(UserProfileModel profile) async {
    await _client.from('profiles').upsert(profile.toMap());
  }

  /// LİNKLER (user_links)

  Future<List<UserLinkModel>> getUserLinks(String profileId) async {
    final response = await _client
        .from('user_links')
        .select()
        .eq('profile_id', profileId)
        .order('order_index', ascending: true);

    return response.map((map) => UserLinkModel.fromMap(map)).toList();
  }

  Future<void> upsertUserLink(UserLinkModel link) async {
    await _client.from('user_links').upsert(link.toMap());
  }

  Future<void> deleteUserLink(String linkId) async {
    await _client.from('user_links').delete().eq('id', linkId);
  }
}
