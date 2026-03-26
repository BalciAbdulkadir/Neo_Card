import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) throw Exception('Kritik Hata: .env dosyasında SUPABASE_URL bulunamadı!');
    return url;
  }
  
  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) throw Exception('Kritik Hata: .env dosyasında SUPABASE_ANON_KEY bulunamadı!');
    return key;
  }
}
