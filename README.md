# 📇 Neo Card -  NFC Dijital Kimlik Sistemi

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

---

# 📇 Neo Card - NFC Digital Identity System

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-%3E%3D3.10-blue?logo=flutter)
![State Management](https://img.shields.io/badge/State%20Management-Riverpod-blueviolet)
![Database](https://img.shields.io/badge/Backend-Supabase-green?logo=supabase)

In this full-stack Flutter project where I combine physical hardware (NFC) with modern web technologies, I have designed an end-to-end system that transforms physical business cards into dynamic digital identities.

## 🚀 Architectural Highlights
* **Hardware Integration (NFC/NDEF):** Established byte-level communication with physical NTAG215 chips, implementing native hardware bridges (NFC Manager) to enable zero-latency NDEF writing of digital profile URLs directly to the hardware.
* **Reactive State Management & Data Flow:** Managed complex internal data flows (user profiles, links, UI states) using the Riverpod architecture to ensure asynchronous and high-performance UI updates.
* **Backend as a Service (BaaS) & Security:** Integrated Supabase for robust authentication and real-time relational database management. Ensured secure handling of user data (1:N relational social media links).
* **Dynamic Web Showcase & Routing:** Developed SEO-friendly web profiles hosted on Vercel using GoRouter and Path URL Strategy (Hash-free routing), providing cross-platform access in seconds.
* **User Experience (UI/UX):** Reduced server load by optimizing local media processing (Image Compression) and delivered a modern interface compliant with platform-specific design guidelines.

## 🛠️ Technologies Used
* **Frontend:** Flutter (Mobile & Web)
* **State Management:** Riverpod
* **Backend:** Supabase (Auth, Postgres)
* **Hardware Integration:** NFC Manager, NDEF
* **Routing:** GoRouter
* **Hosting:** Vercel

## 📦 Installation and Setup

1. Clone the repository:
```bash
git clone [https://github.com/BalciAbdulkadir/Neo_Card.git](https://github.com/BalciAbdulkadir/Neo_Card.git)
```

2. Install dependencies:
```bash
flutter pub get
```

3. Create a `.env` file in the root directory and enter your Supabase credentials:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. Run the application:
```bash
flutter run
```

## 📄 License
This project is licensed under the MIT License. See the LICENSE file for details.
