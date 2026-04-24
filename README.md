# 📇 Neo Card - NFC Tabanlı Dijital Kartvizit

Bu proje, fiziksel NFC kartlarını (NTAG215 vb.) modern ve dinamik bir dijital kimliğe dönüştüren, Flutter ile geliştirilmiş uçtan uca bir sistemdir. Kullanıcılar bilgilerini güncelleyebilir, verilerini NFC çipine kazıyabilir ve kartı dokundurdukları anda özelleştirilmiş profillerini web üzerinden paylaşabilirler.

## 🚀 Öne Çıkan Özellikler

- **NFC/NDEF Yazma:** Verileri doğrudan fiziksel çipe NDEF formatında, bayt seviyesinde hassasiyetle kazır.
- **Supabase Entegrasyonu:** Güçlü kimlik doğrulama (Auth) ve gerçek zamanlı veritabanı yönetimi.
- **Dinamik Profil Yönetimi:** Riverpod ile yönetilen esnek veri yapısı ve görsel düzenleyici.
- **Web Vitrini:** Vercel üzerinde barındırılan, SEO dostu ve hızlı yüklenen kullanıcı profilleri.
- **Modern UI/UX:** Platform spesifik renk vurguları, derinlikli kart tasarımları ve akıllı ikon yönetimi.

## 🛠️ Teknik Yığın (Tech Stack)

- **Framework:** Flutter (Android, Web)
- **State Management:** Flutter Riverpod
- **Backend:** Supabase (Auth & Database)
- **NFC:** nfc_manager & nfc_manager_ndef
- **Deployment:** Vercel (Web Hosting)

## 📦 Kurulum ve Çalıştırma

1. Projeyi klonlayın.
2. `lib/core/config/app_config.dart` içindeki Supabase anahtarlarını kendi bilgilerinizle güncelleyin.
3. Bağımlılıkları yükleyin: `flutter pub get`
4. Uygulamayı çalıştırın: `flutter run`

## 📝 Notlar
Bu uygulama, geliştirme aşamasında `neocard-one.vercel.app` üzerinden test edilmiştir. NFC yazma işlemi için Android cihazlarda NFC izni verilmiş olmalıdır.

---
*Developed with Balci*
