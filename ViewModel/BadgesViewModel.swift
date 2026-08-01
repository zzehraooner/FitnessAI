import Foundation
import Combine

class BadgesViewModel: ObservableObject {
    @Published var totalReps: Int = 0
    @Published var allBadges: [Badge] = []
    @Published var unlockedBadges: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let manager = GamificationManager.shared
    
    init() {
        // Sync state from GamificationManager
        manager.$totalReps
            .assign(to: \.totalReps, on: self)
            .store(in: &cancellables)
            
        manager.$unlockedBadges
            .assign(to: \.unlockedBadges, on: self)
            .store(in: &cancellables)
            
        self.allBadges = manager.allBadges
    }
}
