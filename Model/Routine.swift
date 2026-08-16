import Foundation
import SwiftUI

struct Routine: Identifiable {
    var id = UUID()
    let title: String
    let description: String
    let exercises: [(ExerciseType, Int)] // (Egzersiz, Tekrar sayısı)
    let color: Color
    let difficulty: RoutineDifficulty
    let estimatedMinutes: Int
    let imageSystemName: String

    init(title: String,
         description: String,
         exercises: [(ExerciseType, Int)],
         color: Color,
         difficulty: RoutineDifficulty = .beginner,
         estimatedMinutes: Int = 10,
         imageSystemName: String = "figure.strengthtraining.traditional") {
        self.title = title
        self.description = description
        self.exercises = exercises
        self.color = color
        self.difficulty = difficulty
        self.estimatedMinutes = estimatedMinutes
        self.imageSystemName = imageSystemName
    }
}

enum RoutineDifficulty: String {
    case beginner   = "Başlangıç"
    case intermediate = "Orta"
    case advanced   = "İleri"
    case hiit       = "HIIT"
    case yoga       = "Yoga"

    var color: Color {
        switch self {
        case .beginner:     return .green
        case .intermediate: return .orange
        case .advanced:     return .red
        case .hiit:         return .purple
        case .yoga:         return .teal
        }
    }

    var iconName: String {
        switch self {
        case .beginner:     return "1.circle.fill"
        case .intermediate: return "2.circle.fill"
        case .advanced:     return "3.circle.fill"
        case .hiit:         return "bolt.circle.fill"
        case .yoga:         return "figure.yoga"
        }
    }
}
