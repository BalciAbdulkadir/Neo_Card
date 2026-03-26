import 'package:flutter_test/flutter_test.dart';
import 'package:neo_cord_v2/features/editor/data/user_profile_model.dart';
import 'package:neo_cord_v2/features/editor/data/user_link_model.dart';

void main() {
  group('UserProfileModel Testleri', () {
    test('toMap() null olmayan değerleri doğru şekilde Map objesine çevirmeli', () {
      final model = UserProfileModel(
        id: 'uuid-1234',
        fullName: 'Abdülkadir Balcı',
        jobTitle: 'Flutter Developer',
        email: 'iletisim@test.com',
        phoneNumber: '+905554443322',
        themeColor: '#FF0000',
      );

      final map = model.toMap();
      
      expect(map['id'], 'uuid-1234');
      expect(map['full_name'], 'Abdülkadir Balcı');
      expect(map['job_title'], 'Flutter Developer');
      expect(map['email'], 'iletisim@test.com');
      expect(map['phone_number'], '+905554443322');
      expect(map['theme_color'], '#FF0000');
      expect(map.containsKey('avatar_url'), isFalse, reason: 'avatarUrl null olduğu için map içine eklenmemeli');
    });

    test('fromMap() veritabanından gelen veriyi doğru modele eşlemeli', () {
      final map = {
        'id': 'uuid-5678',
        'full_name': 'Muhammed',
        'created_at': '2026-03-24T12:00:00Z',
      };

      final model = UserProfileModel.fromMap(map);

      expect(model.id, 'uuid-5678');
      expect(model.fullName, 'Muhammed');
      expect(model.jobTitle, isNull);
      expect(model.createdAt, DateTime.parse('2026-03-24T12:00:00Z'));
    });
  });

  group('UserLinkModel Testleri', () {
    test('toMap() uuid ve default değerler ile kusursuz dönüştürmeli', () {
      final link = UserLinkModel(
        profileId: 'uuid-1234',
        platform: 'github',
        url: 'https://github.com/abc',
      );

      final map = link.toMap();

      expect(map.containsKey('id'), isFalse, reason: 'id null olduğu için (henüz db insert olmadı) map e girmemeli');
      expect(map['profile_id'], 'uuid-1234');
      expect(map['platform'], 'github');
      expect(map['is_active'], true); // default değer
      expect(map['order_index'], 0); // default değer
    });

    test('fromMap() DB map verisinden object oluşturmalı', () {
      final map = {
        'id': 'link-999',
        'profile_id': 'uuid-1234',
        'platform': 'linkedin',
        'url': 'https://linkedin.com/in/abc',
        'is_active': false,
        'order_index': 5,
      };

      final link = UserLinkModel.fromMap(map);

      expect(link.id, 'link-999');
      expect(link.profileId, 'uuid-1234');
      expect(link.platform, 'linkedin');
      expect(link.url, 'https://linkedin.com/in/abc');
      expect(link.isActive, false);
      expect(link.orderIndex, 5);
    });
  });
}
