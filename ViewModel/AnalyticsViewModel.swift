import Foundation
import Combine

class AnalyticsViewModel: ObservableObject {
    @Published var workoutSessions: [WorkoutSession] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        let calendar = Calendar.current
        let today = Date()
        
        self.workoutSessions = [
            WorkoutSession(exerciseName: "Squat", totalReps: 45, durationSeconds: 300, averageFormPercentage: 92.5, date: calendar.date(byAdding: .day, value: -6, to: today)!),
            WorkoutSession(exerciseName: "Şınav", totalReps: 20, durationSeconds: 150, averageFormPercentage: 85.0, date: calendar.date(byAdding: .day, value: -5, to: today)!),
            WorkoutSession(exerciseName: "Squat", totalReps: 60, durationSeconds: 400, averageFormPercentage: 95.0, date: calendar.date(byAdding: .day, value: -4, to: today)!),
            WorkoutSession(exerciseName: "Tree Pose", totalReps: 1, durationSeconds: 60, averageFormPercentage: 88.0, date: calendar.date(byAdding: .day, value: -3, to: today)!),
            WorkoutSession(exerciseName: "Squat", totalReps: 30, durationSeconds: 200, averageFormPercentage: 90.0, date: calendar.date(byAdding: .day, value: -2, to: today)!),
            WorkoutSession(exerciseName: "Şınav", totalReps: 25, durationSeconds: 180, averageFormPercentage: 87.0, date: calendar.date(byAdding: .day, value: -1, to: today)!),
            WorkoutSession(exerciseName: "Squat", totalReps: 50, durationSeconds: 320, averageFormPercentage: 96.0, date: today)
        ]
    }
    
    // Grafikler için yardımcı veriler
    var exerciseDistribution: [(name: String, count: Int)] {
        var dict = [String: Int]()
        for session in workoutSessions {
            dict[session.exerciseName, default: 0] += session.totalReps
        }
        return dict.map { (name: $0.key, count: $0.value) }.sorted(by: { $0.count > $1.count })
    }
    
    var dailyReps: [(date: Date, count: Int)] {
        var dict = [Date: Int]()
        let calendar = Calendar.current
        for session in workoutSessions {
            let startOfDay = calendar.startOfDay(for: session.date)
            dict[startOfDay, default: 0] += session.totalReps
        }
        return dict.map { (date: $0.key, count: $0.value) }.sorted(by: { $0.date < $1.date })
    }
}
