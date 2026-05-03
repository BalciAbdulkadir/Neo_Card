# 📇 Neo Card - Uçtan Uca NFC Dijital Kimlik Sistemi

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.10-blue?logo=flutter)
![State Management](https://img.shields.io/badge/State%20Management-Riverpod-blueviolet)
![Database](https://img.shields.io/badge/Backend-Supabase-green?logo=supabase)

Fiziksel donanım (NFC) ile modern web teknolojilerini bir araya getirdiğim bu full-stack Flutter projesinde, fiziksel kartvizitleri dinamik bir dijital kimliğe dönüştüren uçtan uca bir sistem kurguladım.

## 🚀 Öne Çıkan Mimari Dokunuşlar
* **Donanım Entegrasyonu (NFC/NDEF):** Fiziksel NTAG215 çipleriyle bayt seviyesinde iletişim kurarak, kullanıcıların dijital profil URL'lerini doğrudan donanıma NDEF formatında ve sıfır gecikmeyle yazma işlemi sağlayan yerel donanım köprülerini (NFC Manager) kurguladım.
* **Reaktif State Yönetimi & Veri Akışı:** Uygulama içindeki karmaşık veri akışlarını (kullanıcı profili, linkler, UI durumları) Riverpod mimarisiyle yöneterek, UI güncellemelerinin asenkron ve yüksek performanslı gerçekleşmesini sağladım.
* **Backend as a Service (BaaS) & Güvenlik:** Güçlü kimlik doğrulama (Auth) ve gerçek zamanlı ilişkisel veritabanı yönetimi için Supabase'i sisteme entegre ettim. Kullanıcı verilerinin (1:N ilişkili sosyal medya linkleri) yönetimini güvenli bir şekilde sağladım.
* **Dinamik Web Vitrini & Yönlendirme (Routing):** GoRouter ve Path URL Strategy (Hash-free routing) kullanarak, kullanıcıların platform bağımsız şekilde saniyeler içinde erişebileceği, Vercel üzerinde barındırılan SEO dostu web profilleri oluşturdum.
* **Kullanıcı Deneyimi (UI/UX):** Medya işleme (Image Compress) süreçlerini yerelde optimize ederek sunucu yükünü azalttım ve platform spesifik tasarım kurallarına uygun, modern bir arayüz sundum.

## 🛠️ Kullanılan Teknolojiler
* **Frontend:** Flutter (Mobile & Web)
* **State Management:** Riverpod
* **Backend:** Supabase (Auth, Postgres)
* **Donanım Entegrasyonu:** NFC Manager, NDEF
* **Yönlendirme:** GoRouter
* **Hosting:** Vercel

## 📦 Kurulum ve Çalıştırma

1. Projeyi klonlayın:
```bash
git clone [https://github.com/BalciAbdulkadir/Neo_Card.git](https://github.com/BalciAbdulkadir/Neo_Card.git)
```

2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. Kök dizinde bir `.env` dosyası oluşturun ve Supabase bilgilerinizi girin:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. Uygulamayı çalıştırın:
```bash
flutter run
```

## 📄 Lisans
Bu proje MIT Lisansı altında lisanslanmıştır. Detaylar için LICENSE dosyasına bakabilirsiniz.
