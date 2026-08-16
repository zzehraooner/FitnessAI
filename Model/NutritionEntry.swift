import Foundation

// MARK: - Beslenme Modeli

struct NutritionEntry: Identifiable, Codable {
    let id: UUID
    let name: String
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let date: Date
    let icon: String
    
    init(id: UUID = UUID(), name: String, calories: Double, protein: Double, carbs: Double, fat: Double, date: Date = Date(), icon: String = "🍽") {
        self.id = id
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.date = date
        self.icon = icon
    }
}

// MARK: - Beslenme Hedefleri

struct NutritionGoals: Codable {
    var targetCalories: Double = 2500
    var targetProtein: Double = 150  // gram
    var targetCarbs: Double = 300    // gram
    var targetFat: Double = 80       // gram
}
