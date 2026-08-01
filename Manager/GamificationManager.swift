import Foundation
import Combine
import SwiftUI

class GamificationManager: ObservableObject {
    static let shared = GamificationManager()
    
    @Published var totalReps: Int = 0
    @Published var unlockedBadges: [String] = []
    
    // Tüm rozetler (Ödül Sistemi)
    let allBadges: [Badge] = [
        Badge(id: "first_blood", name: "İlk Kan", iconName: "drop.fill", description: "İlk 10 tekrarını tamamla", requiredReps: 10),
        Badge(id: "bronze_warrior", name: "Bronz Savaşçı", iconName: "medal.fill", description: "50 tekrar yap", requiredReps: 50),
        Badge(id: "silver_knight", name: "Gümüş Şövalye", iconName: "shield.fill", description: "100 tekrar yap", requiredReps: 100),
        Badge(id: "iron_legs", name: "Demir Bacak", iconName: "figure.walk", description: "250 tekrar yap", requiredReps: 250),
        Badge(id: "golden_god", name: "Altın Tanrı", iconName: "crown.fill", description: "500 tekrar yap", requiredReps: 500),
        Badge(id: "fitness_monster", name: "Fitness Canavarı", iconName: "flame.fill", description: "1000 tekrar yap", requiredReps: 1000)
    ]
    
    private init() {
        loadData()
    }
    
    func addRep() {
        totalReps += 1
        saveData()
        checkBadges()
    }
    
    private func checkBadges() {
        for badge in allBadges {
            if totalReps >= badge.requiredReps && !unlockedBadges.contains(badge.id) {
                // Yeni rozet açıldı!
                unlockedBadges.append(badge.id)
                saveData()
                
                // Kullanıcıya sesli müjde ver
                SpeechManager.shared.speak("Tebrikler! \(badge.name) rozetini kazandınız!", force: true)
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }
    }
    
    private func saveData() {
        UserDefaults.standard.set(totalReps, forKey: "totalReps")
        UserDefaults.standard.set(unlockedBadges, forKey: "unlockedBadges")
    }
    
    private func loadData() {
        totalReps = UserDefaults.standard.integer(forKey: "totalReps")
        if let savedBadges = UserDefaults.standard.array(forKey: "unlockedBadges") as? [String] {
            unlockedBadges = savedBadges
        }
    }
}
