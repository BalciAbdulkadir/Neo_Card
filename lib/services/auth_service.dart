import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //ANONİM GİRİŞ
  Future<User?> signInAnonymously() async {
    try {
      if (_auth.currentUser != null) {
        return _auth.currentUser;
      }

      UserCredential credential = await _auth.signInAnonymously();
      return credential.user;
    } catch (e) {
      print("HAYALET GİRİŞ HATASI: $e");
      return null;
    }
  }

  //kullanici girdi mi cikti mi uygulamanın baktığı yer burası
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // o an uygulamada olan kullanicinin ID'si alınr
  String? get currentUid => _auth.currentUser?.uid;
}
