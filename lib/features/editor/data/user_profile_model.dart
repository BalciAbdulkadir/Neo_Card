class UserProfileModel {
  final String id;
  final String? fullName;
  final String? jobTitle;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? themeColor;
  final DateTime? createdAt;

  UserProfileModel({
    required this.id,
    this.fullName,
    this.jobTitle,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.themeColor,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      if (fullName != null) 'full_name': fullName,
      if (jobTitle != null) 'job_title': jobTitle,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (themeColor != null) 'theme_color': themeColor,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String?,
      jobTitle: map['job_title'] as String?,
      email: map['email'] as String?,
      phoneNumber: map['phone_number'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      themeColor: map['theme_color'] as String?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : null,
    );
  }

  UserProfileModel copyWith({
    String? id,
    String? fullName,
    String? jobTitle,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? themeColor,
    DateTime? createdAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      themeColor: themeColor ?? this.themeColor,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
