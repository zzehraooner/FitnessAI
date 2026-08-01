import Foundation
import Combine

class WorkoutRoutineViewModel: ObservableObject {
    @Published var routines: [Routine] = [
        Routine(title: "Başlangıç Bacak", description: "Bacak kaslarınızı güçlendirmek için harika bir başlangıç.", exercises: [(.squat, 20)], color: .blue),
        Routine(title: "Üst Vücut (Push)", description: "Göğüs, omuz ve arka kollar için zorlu bir rutin.", exercises: [(.pushup, 15)], color: .orange),
        Routine(title: "Tam Vücut Yakıcı", description: "Hem bacak hem üst vücut, kalori düşmanı rutin.", exercises: [(.squat, 15), (.pushup, 10)], color: .red)
    ]
    
    @Published var showingAddRoutine = false
    @Published var showingPaywall = false
    
    let storeManager: StoreManager
    
    init(storeManager: StoreManager) {
        self.storeManager = storeManager
    }
    
    func createCustomRoutineTapped() {
        if storeManager.isPremiumUser {
            showingAddRoutine = true
        } else {
            showingPaywall = true
        }
    }
    
    func addRoutine(_ routine: Routine) {
        routines.append(routine)
    }
}
