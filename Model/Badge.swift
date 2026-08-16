import Foundation
import SwiftUI

enum BadgeRarity: String, Codable {
    case common    // Gri
    case rare      // Mavi
    case epic      // Mor
    case legendary // Altın

    var color: Color {
        switch self {
        case .common:    return .gray
        case .rare:      return .blue
        case .epic:      return .purple
        case .legendary: return Color(red: 1.0, green: 0.8, blue: 0.0)
        }
    }

    var label: String {
        switch self {
        case .common:    return "Yaygın"
        case .rare:      return "Nadir"
        case .epic:      return "Epik"
        case .legendary: return "Efsanevi"
        }
    }
}

struct Badge: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let iconName: String
    let description: String
    let requiredReps: Int
    var rarity: BadgeRarity = .common
}
