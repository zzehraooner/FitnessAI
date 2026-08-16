import SwiftUI

struct LeaderboardView: View {
    @StateObject private var socialManager = SocialManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    
                    // Başlık
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Liderlik Tablosu")
                            .font(.largeTitle).fontWeight(.heavy).foregroundColor(.white)
                        Text("En iyiler arasına gir, rozetlerini göster!")
                            .font(.subheadline).foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    // Liste
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(socialManager.leaderboard.enumerated()), id: \.element.id) { index, entry in
                                LeaderboardRow(entry: entry, rank: index + 1)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                socialManager.fetchLeaderboard()
                
                // Kendi XP'mizi senkronize edelim (Gerçekte userName Auth'tan veya User profile'dan gelir)
                socialManager.syncMyScore(
                    totalXP: GamificationManager.shared.totalXP,
                    level: GamificationManager.shared.level,
                    userName: "Ben (Zehra)"
                )
            }
        }
    }
}

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let rank: Int
    
    private var rankColor: Color {
        switch rank {
        case 1: return Color.yellow
        case 2: return Color.gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return Color.white.opacity(0.1)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            
            // Sıralama Numarası
            ZStack {
                Circle()
                    .fill(rank <= 3 ? rankColor.opacity(0.2) : Color.clear)
                    .frame(width: 40, height: 40)
                
                if rank <= 3 {
                    Circle()
                        .stroke(rankColor, lineWidth: 2)
                        .frame(width: 40, height: 40)
                }
                
                Text("\(rank)")
                    .font(.headline).fontWeight(.bold)
                    .foregroundColor(rank <= 3 ? rankColor : .gray)
            }
            
            // Avatar
            Image(systemName: entry.avatarIcon)
                .font(.title2)
                .foregroundColor(.cyan)
                .frame(width: 40, height: 40)
                .background(Color.cyan.opacity(0.15))
                .clipShape(Circle())
            
            // İsim & Seviye
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.userName)
                    .font(.headline).fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("Seviye \(entry.level)")
                    .font(.caption2).foregroundColor(.gray)
            }
            
            Spacer()
            
            // XP
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(entry.totalXP)")
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundColor(.orange)
                Text("XP")
                    .font(.caption2).foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
}
