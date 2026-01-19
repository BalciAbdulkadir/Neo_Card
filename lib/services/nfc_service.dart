// Dosya: lib/services/nfc_service.dart

import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  // NFC MÜSAİT Mİ?
  Future<bool> checkAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    return isAvailable;
  }

  // WRITE URL (Karta Link Yazma - v3.3.0 Uyumlu)
  Future<void> writeNfc(String url, {bool lock = false}) async {
    // VERSİYON 3.3.0 DÜZELTMESİ:
    // Eski versiyonda "a/b" ayrımı yoktur, genel standartlar vardır.

    await NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443, // Genel standart (Type A ve B'yi kapsar)
        NfcPollingOption.iso15693, // Vicinity kartlar
      },
      onDiscovered: (NfcTag tag) async {
        try {
          Ndef? ndef = Ndef.from(tag);

          if (ndef == null) {
            throw Exception("Kart NDEF formatını desteklemiyor.");
          }

          if (!ndef.isWritable) {
            throw Exception("Bu kart KİLİTLİ. Yazılamaz.");
          }

          // Link kaydını oluştur
          NdefRecord linkRecord = NdefRecord.createUri(Uri.parse(url));
          NdefMessage message = NdefMessage([linkRecord]);

          // Karta yaz
          await ndef.write(message);

          // VERSİYON 3.3.0 DÜZELTMESİ:
          // 'canMakeReadOnly' özelliği bu sürümde yok.
          // O yüzden sadece 'lock' istenmişse direkt deniyoruz.
          if (lock) {
            await ndef.writeLock();
          }

          // İşlem başarılı, kapat
          await NfcManager.instance.stopSession();
        } catch (e) {
          print("NFC Yazma Hatası: $e");
          await NfcManager.instance.stopSession(
            errorMessage: "Yazma başarısız: ${e.toString()}",
          );
        }
      },

      onError: (e) async {
        print("NFC Oturum Hatası: $e");
      },
    );
  }
}
