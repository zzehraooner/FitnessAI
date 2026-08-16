import Foundation
import SwiftUI

// MARK: - Egzersiz Animasyon Adımı

struct ExerciseStep: Identifiable {
    let id = UUID()
    let phase: String          // "Hazırlık", "İniş", "Tırmanma"
    let description: String
    let systemIcon: String
    let accentColor: Color
    let durationSeconds: Double
}

// MARK: - Guided Workout Manager

class GuidedWorkoutManager: ObservableObject {
    static let shared = GuidedWorkoutManager()

    @Published var currentStepIndex: Int = 0
    @Published var isPlaying: Bool = false
    @Published var countdownValue: Int = 3
    @Published var isCountingDown: Bool = false

    private var timer: Timer?

    // MARK: - Her Egzersiz için Rehber Adımlar

    static func steps(for exercise: ExerciseType) -> [ExerciseStep] {
        switch exercise {

        case .squat:
            return [
                ExerciseStep(phase: "Başlangıç Pozisyonu",
                             description: "Ayaklarını omuz genişliğinde aç. Ayak uçların hafifçe dışa baksın.",
                             systemIcon: "figure.stand",
                             accentColor: .cyan, durationSeconds: 3),
                ExerciseStep(phase: "İniş",
                             description: "Kalçanı geriye ve aşağıya it. Dizlerin ayak uçlarını geçmesin.",
                             systemIcon: "chevron.down.circle.fill",
                             accentColor: .orange, durationSeconds: 2),
                ExerciseStep(phase: "Alt Nokta",
                             description: "Uyluğun yere paralel. Sırtın düz, göğsün açık tutun.",
                             systemIcon: "checkmark.circle.fill",
                             accentColor: .green, durationSeconds: 1),
                ExerciseStep(phase: "Kalkış",
                             description: "Topuklardan güç alarak yukarı it. Nefes ver.",
                             systemIcon: "chevron.up.circle.fill",
                             accentColor: .cyan, durationSeconds: 2),
            ]

        case .pushup:
            return [
                ExerciseStep(phase: "Plank Pozisyonu",
                             description: "Ellerini omuz genişliğinden biraz daha geniş koy. Vücudun düz bir çizgi oluştursun.",
                             systemIcon: "figure.core.training",
                             accentColor: .orange, durationSeconds: 3),
                ExerciseStep(phase: "İniş",
                             description: "Dirseklerin 45° açıyla vücuduna yakın tutarak aşağıya in.",
                             systemIcon: "arrow.down.circle.fill",
                             accentColor: .red, durationSeconds: 2),
                ExerciseStep(phase: "Kalkış",
                             description: "Göğüs kaslarını sıkarak yukarı it. Nefes ver.",
                             systemIcon: "arrow.up.circle.fill",
                             accentColor: .green, durationSeconds: 2),
            ]

        case .lunge:
            return [
                ExerciseStep(phase: "Ayakta Dur",
                             description: "Dik dur, çekirdek kaslarını sık.",
                             systemIcon: "figure.stand",
                             accentColor: .cyan, durationSeconds: 2),
                ExerciseStep(phase: "Adım At",
                             description: "Bir adım ileri at. Ön diz 90° açıda olsun.",
                             systemIcon: "figure.walk",
                             accentColor: .orange, durationSeconds: 2),
                ExerciseStep(phase: "İn",
                             description: "Arka diz yere yaklaştır ama değdirme. Gövdeni dik tut.",
                             systemIcon: "chevron.down.circle.fill",
                             accentColor: .red, durationSeconds: 2),
                ExerciseStep(phase: "Kalk",
                             description: "Ön topuğundan güç al ve başlangıç pozisyonuna dön.",
                             systemIcon: "arrow.up.circle.fill",
                             accentColor: .green, durationSeconds: 2),
            ]

        case .treePose:
            return [
                ExerciseStep(phase: "Hazırlık",
                             description: "Ayaklarını birleştir, gözlerini bir noktaya sabitle.",
                             systemIcon: "eye.fill",
                             accentColor: .green, durationSeconds: 3),
                ExerciseStep(phase: "Denge",
                             description: "Bir ayağını diğerinin iç uyluğuna ya da baldırına koy. Asla dize basmayın.",
                             systemIcon: "figure.yoga",
                             accentColor: .green, durationSeconds: 4),
                ExerciseStep(phase: "Kollar",
                             description: "Ellerin göğsünde birleştir veya yukarı uzat.",
                             systemIcon: "hands.sparkles.fill",
                             accentColor: .purple, durationSeconds: 4),
                ExerciseStep(phase: "Nefes",
                             description: "Derin ve düzenli nefes al. 30 saniye bu pozisyonda kal.",
                             systemIcon: "wind",
                             accentColor: .cyan, durationSeconds: 30),
            ]

        case .bicepCurl:
            return [
                ExerciseStep(phase: "Tutuş",
                             description: "Dambıl/su şişeni nötral tutuşla tut. Dirseğin vücuduna yakın.",
                             systemIcon: "dumbbell.fill",
                             accentColor: .orange, durationSeconds: 2),
                ExerciseStep(phase: "Kıvırma",
                             description: "Yavaşça kolunu kıvır, nefes ver. Sadece ön kolu hareket ettir.",
                             systemIcon: "arrow.up.circle.fill",
                             accentColor: .cyan, durationSeconds: 2),
                ExerciseStep(phase: "Kontrollü İniş",
                             description: "Yavaşça ve kontrollü indir — bu fazda da güç var.",
                             systemIcon: "arrow.down.circle.fill",
                             accentColor: .purple, durationSeconds: 3),
            ]

        case .highKnees:
            return [
                ExerciseStep(phase: "Hazır Ol",
                             description: "Hafifçe öne eğil, kolların 90° açıda.",
                             systemIcon: "figure.run",
                             accentColor: .orange, durationSeconds: 2),
                ExerciseStep(phase: "Koş",
                             description: "Dizleri kalça hizasına çek, kollarını salla. Ritim: hızlı!",
                             systemIcon: "bolt.fill",
                             accentColor: .red, durationSeconds: 2),
            ]

        default:
            return [
                ExerciseStep(phase: "Hazırlan",
                             description: "Doğru formu koruyarak egzersizi yap.",
                             systemIcon: "figure.arms.open",
                             accentColor: .cyan, durationSeconds: 3),
                ExerciseStep(phase: "Uygula",
                             description: "Kontrollü hareket et, nefesine dikkat et.",
                             systemIcon: "checkmark.circle.fill",
                             accentColor: .green, durationSeconds: 2),
            ]
        }
    }

    // MARK: - Oynat / Durdur

    func startCountdown(completion: @escaping () -> Void) {
        countdownValue = 3
        isCountingDown = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] t in
            guard let self else { return }
            if self.countdownValue > 1 {
                self.countdownValue -= 1
            } else {
                t.invalidate()
                self.isCountingDown = false
                completion()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        isPlaying = false
        currentStepIndex = 0
    }
}
