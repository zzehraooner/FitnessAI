import Foundation
import SwiftUI

// MARK: - Kas Grubu

enum MuscleGroup: String, CaseIterable, Codable {
    case chest      = "Göğüs"
    case back       = "Sırt"
    case legs       = "Bacak"
    case shoulders  = "Omuz"
    case core       = "Karın"
    case arms       = "Kollar"
    case glutes     = "Kalça"
    case cardio     = "Kardio"

    var color: Color {
        switch self {
        case .chest:     return Color(red: 1.0, green: 0.3, blue: 0.3)
        case .back:      return Color(red: 1.0, green: 0.6, blue: 0.1)
        case .legs:      return Color(red: 0.3, green: 0.7, blue: 1.0)
        case .shoulders: return Color(red: 0.8, green: 0.3, blue: 1.0)
        case .core:      return Color(red: 0.3, green: 1.0, blue: 0.5)
        case .arms:      return Color(red: 1.0, green: 0.9, blue: 0.2)
        case .glutes:    return Color(red: 1.0, green: 0.5, blue: 0.8)
        case .cardio:    return Color(red: 1.0, green: 0.2, blue: 0.2)
        }
    }

    var icon: String {
        switch self {
        case .chest:     return "figure.core.training"
        case .back:      return "figure.rower"
        case .legs:      return "figure.walk"
        case .shoulders: return "figure.arms.open"
        case .core:      return "figure.roll"
        case .arms:      return "dumbbell.fill"
        case .glutes:    return "figure.pilates"
        case .cardio:    return "heart.fill"
        }
    }
}

// MARK: - ExerciseType → Kas Grupları

extension ExerciseType {
    var primaryMuscles: [MuscleGroup] {
        switch self {
        case .squat:          return [.legs, .glutes, .core]
        case .pushup:         return [.chest, .arms, .shoulders]
        case .lunge:          return [.legs, .glutes]
        case .jumpingJacks:   return [.cardio, .legs]
        case .situp:          return [.core]
        case .bicepCurl:      return [.arms]
        case .shoulderPress:  return [.shoulders, .arms]
        case .deadlift:       return [.back, .legs, .glutes]
        case .highKnees:      return [.cardio, .legs, .core]
        case .lateralRaises:  return [.shoulders]
        case .gluteBridge:    return [.glutes, .core]
        case .calfRaises:     return [.legs]
        case .tricepDips:     return [.arms, .chest]
        case .legRaises:      return [.core, .legs]
        case .frontRaises:    return [.shoulders]
        case .mountainClimbers: return [.cardio, .core, .arms]
        case .donkeyKicks:    return [.glutes, .legs]
        case .crunch:         return [.core]
        case .bentOverRow:    return [.back, .arms]
        case .sumoSquat:      return [.legs, .glutes]
        case .goodMornings:   return [.back, .legs]
        case .treePose:       return [.legs, .core]
        case .warriorPose:    return [.legs, .core, .shoulders]
        }
    }

    /// Egzersizin eklem yük skoru (1-5): düşük iyidir
    var jointStressLevel: Int {
        switch self {
        case .deadlift, .squat, .lunge:       return 4
        case .goodMornings, .bentOverRow:     return 3
        case .pushup, .shoulderPress:         return 3
        case .highKnees, .jumpingJacks, .mountainClimbers: return 2
        case .treePose, .warriorPose, .gluteBridge: return 1
        default: return 2
        }
    }
}
