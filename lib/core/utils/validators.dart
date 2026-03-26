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
