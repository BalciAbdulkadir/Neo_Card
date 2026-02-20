# 🪪 Neo Card

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg?style=for-the-badge)

Neo Card, kullanıcıların kendi dijital kimliklerini ve profillerini fiziksel NFC kartlara (özellikle NTAG215) yazıp okuyabilmesini sağlayan, Flutter ve Firebase tabanlı modern bir mobil uygulamadır.

Fiziksel kartvizitlerin sınırlamalarını ortadan kaldırarak, verileri dijital bir profilde tutar ve sadece tek bir dokunuşla bilgilerin paylaşılmasını sağlar.

## ✨ Öne Çıkan Özellikler

- **NFC Okuma ve Yazma:** NTAG215 kartlara anında veri yazma ve okuma işlemleri.
- **Gerçek Zamanlı Veritabanı:** Firebase entegrasyonu ile kullanıcı verilerinin ve profillerinin anlık senkronizasyonu.
- **Güvenli Kimlik Doğrulama:** Firebase Auth ile hızlı ve güvenli kullanıcı giriş/çıkış işlemleri.
- **Medya Yönetimi:** Profil fotoğrafları ve diğer dosyalar için Firebase Storage entegrasyonu.
- **Çapraz Platform:** Android ve iOS cihazlarda sorunsuz çalışan akıcı arayüz.

## 🏗️ Proje Mimarisi

Proje, sürdürülebilirliği ve okunabilirliği artırmak adına katmanlı bir yapıya sahiptir:

```text
lib/
├── models/         # Veri modelleri (Örn: user_model.dart)
├── pages/          # Kullanıcı arayüzü ve ekranlar (Örn: home_page.dart, profile_view_page.dart)
├── services/       # İş mantığı ve dış entegrasyonlar
│   ├── auth_service.dart      # Kimlik doğrulama işlemleri
│   ├── database_service.dart  # Veritabanı (Firestore/Realtime DB) işlemleri
│   ├── nfc_service.dart       # NFC donanım iletişimi
│   └── storage_service.dart   # Dosya yükleme/indirme işlemleri
├── main.dart       # Uygulamanın giriş noktası

🚀 Başlarken

Projeyi kendi bilgisayarında çalıştırmak için aşağıdaki adımları izleyebilirsin.
Gereksinimler

    Flutter SDK (Güncel sürüm)

    Firebase projesi (Google-services.json ve GoogleService-Info.plist dosyaları ayarlanmış olmalı)

    NFC destekli bir fiziksel mobil cihaz (Emülatörler NFC testleri için yetersizdir)

Kurulum

    Depoyu klonlayın: git clone [https://github.com/BalciAbdulkadir/Neo_Card.git](https://github.com/BalciAbdulkadir/Neo_Card.git)
