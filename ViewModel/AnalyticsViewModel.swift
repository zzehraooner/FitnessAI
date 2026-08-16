import Foundation
import Combine

class AnalyticsViewModel: ObservableObject {
    @ObservedObject var store = SessionStore.shared

    private var cancellables = Set<AnyCancellable>()

    init() {
        // SessionStore'daki değişiklikleri dinle
        SessionStore.shared.$sessions
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    // MARK: - Grafik Verileri (SessionStore delegasyonu)

    var workoutSessions: [WorkoutSession]   { store.sessions }
    var dailyReps: [(date: Date, count: Int)]         { store.dailyReps }
    var weeklyVolume: [(date: Date, minutes: Double)] { store.weeklyVolume }
    var exerciseDistribution: [(name: String, count: Int)] { store.exerciseDistribution }
    var formProgressSeries: [WorkoutSession] { store.formProgressSeries }

    // MARK: - Özet İstatistikler

    var currentStreak: Int    { store.currentStreak }
    var bestFormSession: WorkoutSession? { store.bestFormSession }
    var totalReps: Int        { store.totalReps }
    var totalMinutes: Double  { store.totalMinutes }
    var totalSessions: Int    { store.totalSessions }

    var mostFrequentExercise: String {
        store.exerciseDistribution.first?.name ?? "—"
    }
}
