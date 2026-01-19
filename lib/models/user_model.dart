class UserModel {
  final String uid;
  final String name;
  final String jobTitle;
  final String email;
  final String phoneNumber;
  final String profilePhotoUrl;
  final String website;
  final Map<String, dynamic> socialLinks;

  UserModel({
    required this.uid,
    required this.name,
    required this.jobTitle,
    required this.email,
    required this.phoneNumber,
    required this.profilePhotoUrl,
    required this.website,
    required this.socialLinks,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'] ?? '',
      website: map['website'] ?? '',
      socialLinks: Map<String, dynamic>.from(map['socialLinks'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'jobTitle': jobTitle,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePhotoUrl': profilePhotoUrl,
      'website': website,
      'socialLinks': socialLinks,
    };
  }
}
