import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DatabaseService {
  // 'users' koleksiyonuna erişim yetkisi
  final CollectionReference _usersRef = FirebaseFirestore.instance.collection(
    'users',
  );

  // KULLANICIYI KAYDET / GÜNCELLE
  Future<void> saveUser(UserModel user) async {
    try {
      // user.toMap() diyerek veriyi JSON paketine çeviriyoruz
      await _usersRef.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    } catch (e) {
      print("VERİTABANI KAYIT HATASI: $e");
    }
  }

  // ID si verilen kullanıcının verisini çekip ve UserModel'e çeviriyoruz
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _usersRef.doc(uid).get();

      if (doc.exists) {
        // Gelen datayı al, UserModel.fromMap ile nesneye çevir.
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("VERİTABANI OKUMA HATASI: $e");
      return null;
    }
  }
}
