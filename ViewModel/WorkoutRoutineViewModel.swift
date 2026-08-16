import Foundation
import Combine
import SwiftUI

class WorkoutRoutineViewModel: ObservableObject {
    @Published var routines: [Routine] = [
        Routine(
            title: "Başlangıç Bacak",
            description: "Bacak kaslarını güçlendirmek için mükemmel bir giriş. Squat + Lunge kombinasyonu.",
            exercises: [(.squat, 15), (.lunge, 10), (.gluteBridge, 12)],
            color: .green,
            difficulty: .beginner,
            estimatedMinutes: 12,
            imageSystemName: "figure.strengthtraining.traditional"
        ),
        Routine(
            title: "Üst Vücut Push",
            description: "Göğüs, omuz ve arka kollar. Push-up + Shoulder Press + Tricep Dips.",
            exercises: [(.pushup, 15), (.shoulderPress, 12), (.tricepDips, 10), (.frontRaises, 10)],
            color: .orange,
            difficulty: .intermediate,
            estimatedMinutes: 18,
            imageSystemName: "figure.gymnastics"
        ),
        Routine(
            title: "Üst Vücut Pull",
            description: "Sırt ve ikeps kasları. Bent Over Row + Bicep Curl kombinasyonu.",
            exercises: [(.bentOverRow, 12), (.bicepCurl, 15), (.lateralRaises, 12)],
            color: .blue,
            difficulty: .intermediate,
            estimatedMinutes: 15,
            imageSystemName: "figure.rower"
        ),
        Routine(
            title: "Tam Vücut Yakıcı",
            description: "Hem bacak hem üst vücut. Maksimum kalori yakımı için tasarlandı.",
            exercises: [(.squat, 20), (.pushup, 15), (.jumpingJacks, 30), (.lunge, 12), (.crunch, 20)],
            color: .red,
            difficulty: .advanced,
            estimatedMinutes: 25,
            imageSystemName: "flame.fill"
        ),
        Routine(
            title: "HIIT Cardio Blast",
            description: "Yüksek tempo kardiyo. Mountain Climbers + High Knees + Jumping Jacks.",
            exercises: [(.mountainClimbers, 30), (.highKnees, 30), (.jumpingJacks, 40), (.donkeyKicks, 20), (.mountainClimbers, 30)],
            color: .purple,
            difficulty: .hiit,
            estimatedMinutes: 20,
            imageSystemName: "bolt.fill"
        ),
        Routine(
            title: "Yoga Akışı",
            description: "Zihin-beden dengesi. Ağaç Duruşu ve Savaşçı pozu ile esneklik ve denge geliştir.",
            exercises: [(.treePose, 30), (.warriorPose, 30), (.treePose, 30)],
            color: .teal,
            difficulty: .yoga,
            estimatedMinutes: 15,
            imageSystemName: "figure.yoga"
        )
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
