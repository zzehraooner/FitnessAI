import Foundation
import Combine

class SessionStore: ObservableObject {
    static let shared = SessionStore()

    @Published var sessions: [WorkoutSession] = []

    private let storageKey = "fitnessai_sessions"

    private init() {
        load()
    }

    // MARK: - CRUD

    func save(_ session: WorkoutSession) {
        sessions.insert(session, at: 0) // En yeni önde
        persist()
    }

    func deleteAll() {
        sessions = []
        persist()
    }

    // MARK: - Persistence

    private func persist() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([WorkoutSession].self, from: data) else {
            sessions = Self.sampleSessions()
            return
        }
        sessions = decoded
    }

    // MARK: - Analytics Helpers

    /// Son 7 günün günlük toplam tekrarları
    var dailyReps: [(date: Date, count: Int)] {
        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) else { return [] }

        var dict = [Date: Int]()
        for session in sessions where session.date >= startDate {
            let day = calendar.startOfDay(for: session.date)
            dict[day, default: 0] += session.totalReps
        }
        return dict.map { (date: $0.key, count: $0.value) }.sorted { $0.date < $1.date }
    }

    /// Son 7 günün günlük toplam antrenman süresi (dakika)
    var weeklyVolume: [(date: Date, minutes: Double)] {
        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) else { return [] }

        var dict = [Date: Double]()
        for session in sessions where session.date >= startDate {
            let day = calendar.startOfDay(for: session.date)
            dict[day, default: 0] += Double(session.durationSeconds) / 60.0
        }
        return dict.map { (date: $0.key, minutes: $0.value) }.sorted { $0.date < $1.date }
    }

    /// Egzersiz dağılımı (pasta grafik için)
    var exerciseDistribution: [(name: String, count: Int)] {
        var dict = [String: Int]()
        for session in sessions {
            dict[session.exerciseName, default: 0] += session.totalReps
        }
        return dict.map { (name: $0.key, count: $0.value) }.sorted { $0.count > $1.count }
    }

    /// Ardışık antrenman günü serisi (streak)
    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        while true {
            let hasSession = sessions.contains {
                calendar.startOfDay(for: $0.date) == checkDate
            }
            if hasSession {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        return streak
    }

    /// En yüksek form yüzdesine sahip seans
    var bestFormSession: WorkoutSession? {
        sessions.max { $0.averageFormPercentage < $1.averageFormPercentage }
    }

    /// Toplam tekrar sayısı
    var totalReps: Int {
        sessions.reduce(0) { $0 + $1.totalReps }
    }

    /// Toplam antrenman süresi (dakika)
    var totalMinutes: Double {
        sessions.reduce(0.0) { $0 + Double($1.durationSeconds) / 60.0 }
    }

    /// Toplam seans sayısı
    var totalSessions: Int { sessions.count }

    /// Form doğruluğu zaman serisi (çizgi grafik için)
    var formProgressSeries: [WorkoutSession] {
        Array(sessions.reversed().prefix(14))
    }

    // MARK: - Sample Data (İlk Kurulum)
    private static func sampleSessions() -> [WorkoutSession] {
        let calendar = Calendar.current
        let now = Date()

        return [
            WorkoutSession(exerciseName: "Squat",       totalReps: 45, durationSeconds: 300, averageFormPercentage: 92.5, date: calendar.date(byAdding: .day, value: -6, to: now)!, routineTitle: "Başlangıç Bacak"),
            WorkoutSession(exerciseName: "Şınav",       totalReps: 20, durationSeconds: 150, averageFormPercentage: 85.0, date: calendar.date(byAdding: .day, value: -5, to: now)!, routineTitle: "Üst Vücut"),
            WorkoutSession(exerciseName: "Squat",       totalReps: 60, durationSeconds: 400, averageFormPercentage: 95.0, date: calendar.date(byAdding: .day, value: -4, to: now)!, routineTitle: "Başlangıç Bacak"),
            WorkoutSession(exerciseName: "Ağaç Duruşu", totalReps: 1,  durationSeconds: 60,  averageFormPercentage: 88.0, date: calendar.date(byAdding: .day, value: -3, to: now)!, routineTitle: "Yoga Akışı"),
            WorkoutSession(exerciseName: "Squat",       totalReps: 30, durationSeconds: 200, averageFormPercentage: 90.0, date: calendar.date(byAdding: .day, value: -2, to: now)!, routineTitle: "HIIT Yakıcı"),
            WorkoutSession(exerciseName: "Şınav",       totalReps: 25, durationSeconds: 180, averageFormPercentage: 87.0, date: calendar.date(byAdding: .day, value: -1, to: now)!, routineTitle: "Üst Vücut"),
            WorkoutSession(exerciseName: "Squat",       totalReps: 50, durationSeconds: 320, averageFormPercentage: 96.0, date: now,                                                   routineTitle: "Tam Vücut Yakıcı"),
        ]
    }
}
