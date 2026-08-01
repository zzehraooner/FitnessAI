import SwiftUI

struct ShareSummaryView: View {
    let exercise: String
    let reps: Int
    let duration: String
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .padding()
            
            Spacer()
            
            // Paylaşılacak Ana Görsel Alanı (Bu VSTack resme çevrilecek)
            VStack(spacing: 20) {
                Image(systemName: "figure.walk.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.cyan)
                    .padding(.top, 30)
                
                Text("GÜNÜN ANTRENMANI")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Text("\(reps) \(exercise)")
                    .font(.system(size: 45, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                HStack(spacing: 40) {
                    VStack {
                        Text("Süre")
                            .foregroundColor(.gray)
                        Text(duration)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    VStack {
                        Text("Durum")
                            .foregroundColor(.gray)
                        Text("Tamamlandı")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                }
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: [Color.black, Color.blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.cyan.opacity(0.5), lineWidth: 2)
            )
            .padding()
            
            Spacer()
            
            Button(action: {
                shareWorkout()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Instagram / Hikayede Paylaş")
                }
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.cyan)
                .cornerRadius(15)
                .padding(.horizontal)
            }
            .padding(.bottom, 30)
            
            // Konfeti Animasyon Katmanı
            ConfettiView()
                .allowsHitTesting(false)
        }
        }
    }
    
    
    // Görseli paylaşma fonksiyonu
    func shareWorkout() {
        // Bu kısım SwiftUI View'ı UIImage'e çevirir (Basit bir çözüm)
        let image = UIImage(named: "AppIcon") ?? UIImage() // Geçici olarak bir boş resim
        // Gerçek projede UIGraphicsImageRenderer ile View'ı render ederiz.
        // Aşağıdaki kod paylaşım menüsünü açar
        let activityVC = UIActivityViewController(activityItems: [image, "Bugün harika bir antrenman yaptım!"], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true, completion: nil)
        }
    }
}
