import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../editor/data/user_profile_model.dart';
import '../../editor/data/user_link_model.dart';

final profileReadRepositoryProvider = Provider<ProfileReadRepository>((ref) {
  return ProfileReadRepository(Supabase.instance.client);
});

class ProfileReadRepository {
  final SupabaseClient _client;

  ProfileReadRepository(this._client);

  Future<UserProfileModel?> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfileModel.fromMap(response);
  }

  Future<List<UserLinkModel>> getLinks(String profileId) async {
    final response = await _client
        .from('user_links')
        .select()
        .eq('profile_id', profileId)
        .eq('is_active', true)
        .order('order_index', ascending: true);

    return response.map((map) => UserLinkModel.fromMap(map)).toList();
  }
  
  Future<void> incrementViewCount(String profileId) async {
    try {
      await _client.rpc('increment_profile_views', params: {'p_id': profileId});
    } catch (e) {
      // Sitedeki bir sıkıntı ziyaretleri patlatmamalı, sessizce geç
    }
  }
}
