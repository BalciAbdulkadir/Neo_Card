import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return ImagePickerService(Supabase.instance.client);
});

class ImagePickerService {
  final SupabaseClient _client;
  final ImagePicker _picker = ImagePicker();

  ImagePickerService(this._client);

  Future<String?> pickAndUploadImage(String userId) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      final File file = File(image.path);
      
      // We will target a system temp directory, replacing extension with .webp
      final String tempPath = '${file.parent.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.webp';
      
      final XFile? compressedImage = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        tempPath,
        quality: 70, // optimize heavily to ~500kb range
        format: CompressFormat.webp,
        minWidth: 800,
        minHeight: 800,
      );

      if (compressedImage == null) {
        throw Exception("Fotoğraf sıkıştırılırken bir hata oluştu.");
      }

      final File uploadFile = File(compressedImage.path);
      
      // Store in Supabase
      // Using a random naming to avoid heavy cache conflicts without UUID package
      final String fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.webp';

      await _client.storage.from('avatars').upload(
        fileName,
        uploadFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );

      return _client.storage.from('avatars').getPublicUrl(fileName);
    } catch (e) {
      throw Exception('Medya yüklenirken hata oluştu: $e');
    }
  }
}
