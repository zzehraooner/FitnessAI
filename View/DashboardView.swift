import SwiftUI
import Charts

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    
    init(firebaseManager: FirebaseManager) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(healthManager: HealthManager(), firebaseManager: firebaseManager))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Profil ve Karşılama
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Hoş Geldin,")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                                Text(viewModel.userName)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 45))
                                .foregroundColor(.cyan)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal)
                        
                        // İstatistik Kartları (3'lü: Adım, Koşu, Kalori)
                        HStack(spacing: 15) {
                            StatCard(title: "Adım", value: String(format: "%.0f", viewModel.healthManager.dailySteps), icon: "shoeprints.fill", color: .green)
                            StatCard(title: "Kcal", value: String(format: "%.0f", viewModel.healthManager.caloriesBurned), icon: "flame.fill", color: .red)
                            StatCard(title: "Koşu (Dk)", value: String(format: "%.0f", viewModel.healthManager.runningMinutes), icon: "figure.run", color: .orange)
                        }
                        .padding(.horizontal)
                        
                        // Swift Charts - Gelişim Grafiği
                        VStack(alignment: .leading) {
                            Text("Haftalık Adım Gelişimi")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Chart {
                                ForEach(viewModel.healthManager.weeklySteps) { data in
                                    BarMark(
                                        x: .value("Gün", data.day),
                                        y: .value("Adım", data.steps)
                                    )
                                    .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .top, endPoint: .bottom))
                                    .cornerRadius(5)
                                }
                            }
                            .frame(height: 200)
                            .chartYAxis {
                                AxisMarks(position: .leading) { _ in
                                    AxisGridLine().foregroundStyle(.gray.opacity(0.3))
                                    AxisValueLabel().foregroundStyle(.gray)
                                }
                            }
                            .chartXAxis {
                                AxisMarks(position: .bottom) { _ in
                                    AxisValueLabel().foregroundStyle(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Görevler / Meydan Okumalar Butonu
                        NavigationLink(destination: ChallengesView()) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("Görevler ve Meydan Okumalar")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        
                        // Antrenman Planlayıcı Butonu
                        NavigationLink(destination: WorkoutPlannerView()) {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                    .foregroundColor(.cyan)
                                Text("Haftalık Antrenman Planlayıcı")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        
                        // Verileri Buluta Kaydet Butonu
                        Button(action: {
                            viewModel.saveToCloud()
                        }) {
                            HStack {
                                Image(systemName: "icloud.and.arrow.up")
                                Text("Verilerimi Buluta Kaydet")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Özet")
            .navigationBarHidden(true)
        }
    }
}

// StatCard boyutları 3'lü düzene sığması için güncellendi
struct StatCard: View {
    var title: String
    var value: String
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}
