import Foundation

enum ExerciseType: String, CaseIterable {
    case squat = "Squat"
    case pushup = "Şınav (Push-up)"
    case lunge = "Lunge (Hamle)"
    case jumpingJacks = "Jumping Jacks"
    case situp = "Mekik (Sit-up)"
    case bicepCurl = "Dumbell (Bicep Curl)"
    case shoulderPress = "Omuz Presi"
    case deadlift = "Deadlift"
    case highKnees = "Yüksek Diz (High Knees)"
    case lateralRaises = "Yana Açış (Lateral)"
    case gluteBridge = "Kalça Köprüsü"
    case calfRaises = "Kalf Kaldırma"
    case tricepDips = "Arka Kol Dips"
    case legRaises = "Bacak Kaldırma"
    case frontRaises = "Öne Kol Kaldırma"
    case mountainClimbers = "Dağ Tırmanışı"
    case donkeyKicks = "Geriye Tekme"
    case crunch = "Yarım Mekik (Crunch)"
    case bentOverRow = "Eğilerek Çekiş"
    case sumoSquat = "Sumo Squat"
    case goodMornings = "Good Mornings"
    
    // YOGA
    case treePose = "Ağaç Duruşu (Tree Pose)"
    case warriorPose = "Savaşçı (Warrior Pose)"
    
    var isYoga: Bool {
        return self == .treePose || self == .warriorPose
    }
    
    var iconName: String {
        switch self {
        case .squat: return "figure.strengthtraining.traditional"
        case .pushup: return "figure.core.training"
        case .lunge: return "figure.walk"
        case .jumpingJacks: return "figure.jumprope"
        case .situp: return "figure.cooldown"
        case .bicepCurl: return "dumbbell.fill"
        case .shoulderPress: return "figure.gymnastics"
        case .deadlift: return "figure.mixed.cardio"
        case .highKnees: return "figure.run"
        case .lateralRaises: return "figure.arms.open"
        case .gluteBridge: return "figure.pilates"
        case .calfRaises: return "figure.step.training"
        case .tricepDips: return "figure.mind.and.body"
        case .legRaises: return "figure.flexibility"
        case .frontRaises: return "figure.boxing"
        case .mountainClimbers: return "figure.stairs"
        case .donkeyKicks: return "figure.track.and.field"
        case .crunch: return "figure.roll"
        case .bentOverRow: return "figure.rower"
        case .sumoSquat: return "figure.cross.training"
        case .goodMornings: return "figure.stand"
        case .treePose: return "figure.yoga"
        case .warriorPose: return "figure.yoga"
        }
    }
}
