import SwiftUI

struct PaywallView: View {
    @ObservedObject var storeManager: StoreManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // Şık arkaplan
            LinearGradient(colors: [Color.black, Color.purple.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding()
                
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow, radius: 10, x: 0, y: 0)
                
                Text("FitnessAI PRO")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Gerçek potansiyelinizi ortaya çıkarın.")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(icon: "figure.mind.and.body", text: "Kendi Özel Rutinlerini Yarat")
                    FeatureRow(icon: "chart.xyaxis.line", text: "Gelişmiş Yapay Zeka Analizi")
                    FeatureRow(icon: "bolt.fill", text: "Reklamsız Deneyim")
                    FeatureRow(icon: "star.circle.fill", text: "Tüm Meydan Okumaların Kilidini Aç")
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .cornerRadius(20)
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    storeManager.purchasePremium()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Aylık 99.99₺ - Şimdi Başla")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(30)
                        .shadow(color: .orange.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
                
                Button(action: {
                    storeManager.restorePurchases()
                }) {
                    Text("Geçmiş Satın Alımları Geri Yükle")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.6))
                        .underline()
                }
                .padding(.bottom, 20)
            }
        }
    }
}

struct FeatureRow: View {
    var icon: String
    var text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.yellow)
                .frame(width: 30)
            
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}
