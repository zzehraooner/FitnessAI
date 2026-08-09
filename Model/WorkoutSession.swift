import Foundation

struct WorkoutSession: Identifiable, Codable {
    var id = UUID()
    let exerciseName: String
    let totalReps: Int
    let durationSeconds: Int
    let averageFormPercentage: Double
    let date: Date
}
