import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:ndef_record/ndef_record.dart'; // Enumlar ve Record sınıfı buraya taşındı!
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';

final nfcServiceProvider = Provider<NfcService>((ref) {
  return NfcService();
});

class NfcService {
  Future<void> writeNdef(String url) async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      throw Exception('Cihazınızda NFC özelliği bulunmuyor veya kapalı.');
    }

    Completer<void> completer = Completer<void>();

    await NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
        NfcPollingOption.iso18092,
      },
      onDiscovered: (NfcTag tag) async {
        try {
          var ndef = Ndef.from(tag);

          if (ndef == null || !ndef.isWritable) {
            await NfcManager.instance.stopSession();
            if (!completer.isCompleted) {
              completer.completeError(
                'Bu etiket desteklenmiyor veya yazılamaz durumda.',
              );
            }
            return;
          }

          // 1. İŞİN AMELELİĞİ: URL'yi Manuel Byte'a Çeviriyoruz
          // 0x00 = Tüm URL'yi olduğu gibi yaz (Protokol ayıklama fantezisine girmiyoruz)
          Uint8List payload = Uint8List.fromList([0x00, ...utf8.encode(url)]);

          // 2. Manuel NdefRecord İnşaatı (Hazır metotları sildikleri için bunu ellerimizle kuruyoruz)
          NdefRecord uriRecord = NdefRecord(
            typeNameFormat: TypeNameFormat.wellKnown,
            type: Uint8List.fromList([
              0x55,
            ]), // ASCII 'U' harfi (Bunun bir URI olduğunu belirtir)
            identifier: Uint8List(0), // Boş identifier
            payload: payload,
          );

          // 3. NdefMessage oluştururken artık named parameter ('records:') zorunlu!
          NdefMessage message = NdefMessage(records: [uriRecord]);

          // 4. Yazma işleminde de named parameter ('message:') zorunlu!
          await ndef.write(message: message);

          await NfcManager.instance.stopSession();

          if (!completer.isCompleted) {
            completer.complete();
          }
        } catch (e) {
          await NfcManager.instance.stopSession();
          if (!completer.isCompleted) {
            completer.completeError('Yazma hatası: $e');
          }
        }
      },
    );

    return completer.future;
  }
}
