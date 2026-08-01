import SwiftUI

struct BadgesView: View {
    @StateObject private var viewModel = BadgesViewModel()
    
    // Grid yapısı
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Özet Kartı
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Toplam Başarı")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.totalReps) Tekrar")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        Image(systemName: "flame.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Text("Rozetlerin")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    // Rozet Grid'i
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.allBadges) { badge in
                            BadgeCard(badge: badge, isUnlocked: viewModel.unlockedBadges.contains(badge.id))
                        }
                    }
                    .padding(.horizontal)
                    
                }
                .padding(.top)
            }
            .navigationTitle("Başarılar")
        }
    }
}

struct BadgeCard: View {
    let badge: Badge
    let isUnlocked: Bool
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.orange.opacity(0.2) : Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: badge.iconName)
                    .font(.system(size: 35))
                    .foregroundColor(isUnlocked ? .orange : .gray.opacity(0.3))
            }
            
            Text(badge.name)
                .font(.caption)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(isUnlocked ? .primary : .secondary)
            
            Text(badge.description)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isUnlocked ? Color.orange : Color.clear, lineWidth: 2)
        )
        // Kilitli ise gri (soluk) yap
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

struct BadgesView_Previews: PreviewProvider {
    static var previews: some View {
        BadgesView()
    }
}
