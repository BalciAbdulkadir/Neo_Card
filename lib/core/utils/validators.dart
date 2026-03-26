import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class Validators {
  static String formatUrl(String input) {
    if (input.trim().isEmpty) return '';
    var url = input.trim();

    // Check if it already has a protocol, otherwise gracefully append HTTPS
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return url;
  }

  static String formatSocialUrl(String platform, String input) {
    if (input.trim().isEmpty) return '';
    var val = input.trim();
    
    // Zaten http veya https içeriyorsa doğrudan formatUrl'ye at
    if (val.startsWith('http://') || val.startsWith('https://')) {
      return formatUrl(val);
    }

    // Kullanıcı adı girildiyse platformlara göre akıllı prefix at
    switch (platform.toLowerCase()) {
      case 'instagram':
        if (!val.contains('instagram.com')) {
          val = 'https://instagram.com/${val.replaceAll('@', '')}';
        }
        break;
      case 'x':
      case 'twitter':
        if (!val.contains('x.com') && !val.contains('twitter.com')) {
          val = 'https://x.com/${val.replaceAll('@', '')}';
        }
        break;
      case 'linkedin':
        if (!val.contains('linkedin.com')) {
          val = 'https://linkedin.com/in/$val';
        }
        break;
      case 'website':
        val = formatUrl(val);
        break;
      default:
        val = formatUrl(val);
    }
    
    return val.startsWith('http') ? val : 'https://$val';
  }

  static Map<String, String> parsePhone(String input) {
    if (input.trim().isEmpty) return {'countryCode': 'TR', 'number': ''};
    try {
      // E.164 kütüphanesini kullanarak %100 dogru izole eden parser
      final parsed = PhoneNumber.parse(input);
      return {
        'countryCode': parsed.isoCode.name, // IsoCode.TR enum'dan TR döndürür
        'number': parsed.nsn, // National Significant Number (örn: 5551234567)
      };
    } catch (e) {
      // Beklenmeyen veya geçersiz format gelirse default TR fallback kullan
      if (input.startsWith('+')) {
        return {'countryCode': 'TR', 'number': input.replaceAll('+', '')};
      }
      return {'countryCode': 'TR', 'number': input};
    }
  }
}
