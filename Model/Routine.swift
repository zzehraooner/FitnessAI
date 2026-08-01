import Foundation
import SwiftUI

struct Routine: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let exercises: [(ExerciseType, Int)] // Hangi hareketten kaç tane yapılacağı
    let color: Color
}
