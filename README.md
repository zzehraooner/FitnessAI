# FitnessAI 🏋️‍♂️🧘‍♀️

FitnessAI, Yapay Zeka (AI) ve Bilgisayarlı Görü (Computer Vision) teknolojileriyle güçlendirilmiş, iOS tabanlı akıllı bir fitness takip ve koçluk uygulamasıdır. Cihazınızın ön kamerasını kullanarak vücut formunuzu analiz eder, tekrarlarınızı sayar, beslenmenizi takip eder ve size kişisel bir sesli ve yapay zeka koçluk deneyimi sunar.

## 🚀 Öne Çıkan Özellikler

- **Yapay Zeka Destekli Form Takibi**: Apple'ın Vision framework'ünü (`VNDetectHumanBodyPoseRequest`) kullanarak eklem açılarınızı ve hareketlerinizi gerçek zamanlı olarak analiz eder.
- **Akıllı Tekrar Sayacı ve Geri Bildirim**: Squat, Şınav (Push-up) gibi hareketlerde tekrarlarınızı otomatik sayar. Formunuz bozulduğunda anında uyarır ("Daha fazla inin!", "Dizinizi çekin").
- **AI Koç (Gemini Entegrasyonu) 🧠**: Antrenman verilerinizi (tekrar, süre, form yüzdesi) analiz ederek size profesyonel ve motive edici geri bildirimler sunan yapay zeka tabanlı sohbet arayüzü.
- **Vücut Isı Haritası (Heatmap) & Asimetri Analizi**: Antrenman sonrasında hangi kas gruplarının ne kadar çalıştığını, eklem risk skorunuzu ve form hatalarına bağlı asimetrileri analiz eder.
- **Beslenme Takibi 2.0 🥗**: Günlük kalori hedeflerinizi yönetmenizi, protein/karb/yağ makrolarını grafiklerle takip etmenizi ve içtiğiniz su miktarını (Gauge ve Halkalarla) izlemenizi sağlar.
- **Rehberli Antrenman Modu**: Egzersizleri "Aşağı İn", "Bekle", "Kalk" şeklinde adım adım animasyonlu ve görsel yönlendirmelerle yapmanızı sağlar.
- **Haftalık Antrenman Planlayıcı**: Haftanızı gün gün planlayın ve `UNUserNotificationCenter` ile yerel bildirimlerle spor vaktinizi asla kaçırmayın.
- **Oyunlaştırma (Gamification) 2.0 & Rozetler 🏆**: XP (Deneyim Puanı) kazanıp seviye atlayın. Günlük görevleri tamamlayarak Bronz, Gümüş, Altın ve Efsanevi rarity (nadirliğe) sahip onlarca rozet kazanın!
- **Sosyal Liderlik Tablosu 🌍**: Kazandığınız XP'lerle Global Firestore Liderlik Tablosu'nda diğer sporcularla yarışın.
- **Sesli Yapay Zeka Koçu 🗣️**: Ekrana bakmanıza gerek kalmadan, Türkçe olarak tekrarlarınızı sayar ve sizi motive eder (`AVSpeechSynthesizer`).
- **HealthKit Entegrasyonu**: Günlük adım, koşu süresi ve yakılan kalori verilerinizi Apple Health (Sağlık) uygulamasından çeker.
- **Bulut Senkronizasyonu**: Verilerinizi Firebase kullanarak güvenli bir şekilde buluta kaydeder.

## 🛠 Kullanılan Teknolojiler

- **Arayüz (UI)**: SwiftUI
- **Yapay Zeka & Görev Takibi**: Vision Framework, Gemini API (Generative Language)
- **Mimari**: MVVM (Model-View-ViewModel)
- **Backend & Veritabanı**: Firebase Authentication, Firestore
- **Sağlık Verileri**: HealthKit
- **Bildirimler**: UserNotifications (Local)
- **Veri Görselleştirme**: Charts (SwiftUI)
- **Ses & Multimedya**: AVFoundation (Speech Synthesis)

## 📁 Proje Yapısı

Proje modüler MVVM tasarım desenini kullanmaktadır:

- **Models**: Veri yapıları (`Badge`, `Routine`, `ExerciseType`, `NutritionEntry`)
- **ViewModels**: Görünümlerin iş mantığı ve durum (state) yönetimi (`AuthViewModel`, `DashboardViewModel`, `WorkoutRoutineViewModel` vb.)
- **Views**: SwiftUI arayüz bileşenleri (`HomeView`, `AICoachView`, `DashboardView`, `MuscleHeatmapView`, `NutritionView` vb.)
- **Managers / Services**: Çekirdek servisler ve motorlar (`PoseEstimator`, `ExerciseAnalyzer`, `FirebaseManager`, `HealthManager`, `SpeechManager`, `GamificationManager`, `AICoachManager`, `SocialManager`)

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
6. (Opsiyonel) Gemini API Kullanımı: `AICoachManager.swift` içerisinde yer alan API anahtarı bölümüne kendi anahtarınızı girerek canlı veriler çekebilirsiniz.
7. Cihazınızı bağlayın, **Build and Run (Cmd+R)** komutuyla uygulamayı çalıştırın.

## 🔮 Yol Haritası (Roadmap)
- [x] Computer Vision ile Vücut Tespiti
- [x] Biyomekanik Analiz ve Tekrar Sayımı
- [x] Sesli Koç (Vocal Coach) Entegrasyonu
- [x] Oyunlaştırma 2.0, Rozetler ve Günlük Görevler
- [x] Beslenme Makro Takibi ve Vücut Isı Haritası
- [x] AI Koç (Gemini API) ve Sosyal Liderlik Tablosu
- [x] Haftalık Antrenman Planlayıcısı ve Rehberli Antrenman
- [ ] WatchOS Entegrasyonu (Apple Watch Bağımsız Uygulaması)
- [ ] Daha fazla hareket analizi (Deadlift vb.) eklentisi

## 🤝 Katkıda Bulunma
Katkılarınızı bekliyoruz! Büyük değişiklikler yapmadan önce tartışmak için lütfen bir Issue açın.

## 📄 Lisans
Bu proje [MIT](https://choosealicense.com/licenses/mit/) lisansı altındadır.
