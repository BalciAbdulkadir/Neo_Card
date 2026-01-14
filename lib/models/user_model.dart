class UserModel {
  final String uid; // Firebase ID
  final String name;
  final String jobTitle; // Unvan
  final String email;
  final String profilePhoto;
  final Map<String, dynamic> links; // Sosyal Medya Linkleri

  UserModel({
    required this.uid,
    required this.name,
    required this.jobTitle,
    required this.email,
    required this.profilePhoto,
    required this.links,
  });

  // Veritabanından gelen veriyi okur.

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      email: map['email'] ?? '',
      profilePhoto: map['profilePhoto'] ?? '',
      // Linkleri Map formatında alıyoruz
      links: Map<String, dynamic>.from(map['links'] ?? {}),
    );
  }

  // Veritabanına kaydederken kullanırız.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'jobTitle': jobTitle,
      'email': email,
      'profilePhoto': profilePhoto,
      'links': links,
    };
  }
}
