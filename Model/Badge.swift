import Foundation

struct Badge: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let iconName: String
    let description: String
    let requiredReps: Int
}
