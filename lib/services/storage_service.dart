import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  //foto seç
  Future<XFile?> pickImage() async {
    // Galeriyi açar
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  //yüklenen resmin urlsini döndürür.
  Future<String?> uploadProfilePhoto(File file, String uid) async {
    try {
      Reference ref = _storage.ref().child('profile_photos/$uid.jpg');

      // Yüklemeyi başlat
      UploadTask uploadTask = ref.putFile(file);

      TaskSnapshot snapshot = await uploadTask;

      // Linki al ve döndür
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("FOTOĞRAF YÜKLEME HATASI: $e");
      return null;
    }
  }
}
