import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    @Published var healthManager: HealthManager
    let firebaseManager: FirebaseManager
    
    init(healthManager: HealthManager, firebaseManager: FirebaseManager) {
        self.healthManager = healthManager
        self.firebaseManager = firebaseManager
    }
    
    var userName: String {
        return firebaseManager.currentUserEmail.components(separatedBy: "@").first ?? "Sporcu"
    }
    
    func saveToCloud() {
        firebaseManager.saveUserData(steps: healthManager.dailySteps, runningMinutes: healthManager.runningMinutes)
    }
}
