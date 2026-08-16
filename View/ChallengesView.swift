import SwiftUI

struct Challenge: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let targetSteps: Double
    let icon: String
    let color: Color
}

struct ChallengesView: View {
    @StateObject var healthManager = HealthManager()
    
    let challenges: [Challenge] = [
        Challenge(title: "Günlük Adım Ustası", description: "Bugün 10.000 adım at.", targetSteps: 10000, icon: "figure.walk", color: .green),
        Challenge(title: "Hafta Sonu Yürüyüşü", description: "Bugün 15.000 adım atarak sınırlarını zorla.", targetSteps: 15000, icon: "flame.fill", color: .orange)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Görevler (Meydan Okumalar)")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                            .padding(.horizontal)
                        
                        Text("Kendine meydan oku ve altın kupaları kazan!")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        // Liderlik Tablosu Butonu
                        NavigationLink(destination: LeaderboardView()) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .foregroundColor(.yellow)
                                Text("Global Liderlik Tablosu")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.yellow.opacity(0.15))
                            .cornerRadius(15)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.yellow.opacity(0.3), lineWidth: 1))
                        }
                        .padding(.horizontal)
                        
                        ForEach(challenges) { challenge in
                            ChallengeCard(challenge: challenge, currentSteps: healthManager.dailySteps)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ChallengeCard: View {
    let challenge: Challenge
    let currentSteps: Double
    
    var progress: Double {
        min(currentSteps / challenge.targetSteps, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: challenge.icon)
                    .font(.system(size: 40))
                    .foregroundColor(progress >= 1.0 ? .yellow : challenge.color)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(challenge.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(challenge.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if progress >= 1.0 {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.title)
                        .foregroundColor(.yellow)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(progress >= 1.0 ? Color.yellow : challenge.color)
                        .frame(width: max(geometry.size.width * CGFloat(progress), 0), height: 10)
                }
            }
            .frame(height: 10)
            
            HStack {
                Text("\(Int(currentSteps))")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Text("\(Int(challenge.targetSteps))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(progress >= 1.0 ? Color.yellow : Color.clear, lineWidth: 2)
        )
        .padding(.horizontal)
    }
}
