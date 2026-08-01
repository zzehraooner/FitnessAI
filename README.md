# FitnessAI 🏋️‍♂️🧘‍♀️

FitnessAI, Yapay Zeka (AI) ve Bilgisayarlı Görü (Computer Vision) teknolojileriyle güçlendirilmiş, iOS tabanlı akıllı bir fitness takip ve koçluk uygulamasıdır. Cihazınızın ön kamerasını kullanarak vücut formunuzu analiz eder, tekrarlarınızı sayar ve size kişisel bir sesli koçluk deneyimi sunar.

## 🚀 Özellikler

- **Yapay Zeka Destekli Form Takibi**: Apple'ın Vision framework'ünü (`VNDetectHumanBodyPoseRequest`) kullanarak eklem açılarınızı ve hareketlerinizi gerçek zamanlı olarak analiz eder.
- **Akıllı Tekrar Sayacı ve Geri Bildirim**: Squat, Şınav (Push-up) gibi hareketlerde tekrarlarınızı otomatik sayar. Formunuz bozulduğunda anında uyarır ("Daha fazla inin!", "Dizinizi çekin").
- **Yoga ve Stabilite Modu**: Ağaç Duruşu (Tree Pose) ve Savaşçı (Warrior Pose) gibi izometrik duruşları takip eder. Dengede kaldığınız süreyi ölçer, dengeniz bozulduğunda süreyi duraklatır.
- **Sesli Yapay Zeka Koçu 🗣️**: Ekrana bakmanıza gerek kalmadan, Türkçe olarak tekrarlarınızı sayar, formunuzu düzeltir ve sizi motive eder (`AVSpeechSynthesizer`).
- **Oyunlaştırma (Gamification) & Rozetler 🏆**: "İlk Kan", "Demir Bacak", "Fitness Canavarı" gibi rozetlerle spor yapmayı eğlenceli bir oyuna dönüştürür.
- **HealthKit Entegrasyonu**: Günlük adım, koşu süresi ve yakılan kalori verilerinizi Apple Health (Sağlık) uygulamasından çeker.
- **Bulut Senkronizasyonu**: Verilerinizi Firebase kullanarak güvenli bir şekilde buluta kaydeder.
- **MVVM Mimarisi**: Temiz, ölçeklenebilir ve sürdürülebilir Model-View-ViewModel mimarisi üzerine inşa edilmiştir.

## 🛠 Kullanılan Teknolojiler

- **Arayüz (UI)**: SwiftUI
- **Yapay Zeka & Görev Takibi**: Vision Framework
- **Mimari**: MVVM (Model-View-ViewModel)
- **Backend & Veritabanı**: Firebase Authentication, Firestore
- **Sağlık Verileri**: HealthKit
- **Ses & Multimedya**: AVFoundation (Speech Synthesis)

## 📁 Proje Yapısı

Proje modüler MVVM tasarım desenini kullanmaktadır:

- **Models**: Veri yapıları (`Badge`, `Routine`, `ExerciseType`)
- **ViewModels**: Görünümlerin iş mantığı ve durum (state) yönetimi (`AuthViewModel`, `DashboardViewModel`, `WorkoutRoutineViewModel` vb.)
- **Views**: SwiftUI arayüz bileşenleri (`HomeView`, `CameraView`, `DashboardView`, `BadgesView` vb.)
- **Managers / Services**: Çekirdek servisler ve araçlar (`PoseEstimator`, `ExerciseAnalyzer`, `FirebaseManager`, `HealthManager`, `SpeechManager`, `GamificationManager`)

## 🏃‍♂️ Kurulum ve Çalıştırma

### Gereksinimler
- Xcode 15+
- iOS 17.0+
- Fiziksel bir iOS cihazı (Kamera ve HealthKit simülatörde tam çalışmaz)

### Adımlar

1. Repoyu bilgisayarınıza klonlayın:
   ```bash
   git clone https://github.com/your-username/FitnessAI.git
   ```
2. Projeyi Xcode ile açın.
3. **Firebase** Kurulumu:
   - Firebase Console üzerinden yeni bir iOS projesi oluşturun.
   - İndirdiğiniz `GoogleService-Info.plist` dosyasını Xcode projenizin ana dizinine ekleyin.
4. Xcode'da "Signing & Capabilities" sekmesinden **HealthKit** yetkilerini açın.
5. `Info.plist` dosyasına Kamera (`NSCameraUsageDescription`) ve Sağlık Verisi Okuma (`NSHealthShareUsageDescription`) izinleri için gerekli metinleri eklediğinizden emin olun.
6. Cihazınızı bağlayın, **Build and Run (Cmd+R)** komutuyla uygulamayı çalıştırın.

## 🔮 Yol Haritası (Roadmap)
- [x] Computer Vision ile Vücut Tespiti
- [x] Biyomekanik Analiz ve Tekrar Sayımı
- [x] Sesli Koç (Vocal Coach) Entegrasyonu
- [x] Oyunlaştırma ve Rozet Sistemi
- [x] Yoga / Stabilite Ölçüm Modu
- [ ] Hazır Antrenman Programları ve Otomatik Geçişler (Geliştirilme Aşamasında)
- [ ] Apple Watch Entegrasyonu
- [ ] Detaylı Grafikler ve Gelişim Takibi

## 🤝 Katkıda Bulunma
Katkılarınızı bekliyoruz! Büyük değişiklikler yapmadan önce tartışmak için lütfen bir Issue açın.

## 📄 Lisans
Bu proje [MIT](https://choosealicense.com/licenses/mit/) lisansı altındadır.
