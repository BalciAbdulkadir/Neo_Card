class UserLinkModel {
  final String? id; // Can be null before insertion, DB will auto UUID
  final String profileId;
  final String platform;
  final String url;
  final bool isActive;
  final int orderIndex;

  UserLinkModel({
    this.id,
    required this.profileId,
    required this.platform,
    required this.url,
    this.isActive = true,
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'profile_id': profileId,
      'platform': platform,
      'url': url,
      'is_active': isActive,
      'order_index': orderIndex,
    };
  }

  factory UserLinkModel.fromMap(Map<String, dynamic> map) {
    return UserLinkModel(
      id: map['id'] as String?,
      profileId: map['profile_id'] as String,
      platform: map['platform'] as String,
      url: map['url'] as String,
      isActive: map['is_active'] as bool? ?? true,
      orderIndex: map['order_index'] as int? ?? 0,
    );
  }

  UserLinkModel copyWith({
    String? id,
    String? profileId,
    String? platform,
    String? url,
    bool? isActive,
    int? orderIndex,
  }) {
    return UserLinkModel(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      platform: platform ?? this.platform,
      url: url ?? this.url,
      isActive: isActive ?? this.isActive,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
