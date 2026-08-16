import Foundation
import Combine

class NutritionStore: ObservableObject {
    static let shared = NutritionStore()
    
    @Published var entries: [NutritionEntry] = []
    @Published var goals = NutritionGoals()
    @Published var waterGlasses: Int = 0
    
    private let entriesKey = "nutrition_entries"
    private let goalsKey = "nutrition_goals"
    private let waterKey = "nutrition_water"
    private let lastDateKey = "nutrition_last_date"
    
    // Basit bir veritabanı (Sabit yiyecekler)
    let foodDatabase: [NutritionEntry] = [
        NutritionEntry(name: "Yumurta (1 adet)", calories: 72, protein: 6, carbs: 0.4, fat: 5, icon: "🥚"),
        NutritionEntry(name: "Tavuk Göğsü (100g)", calories: 165, protein: 31, carbs: 0, fat: 3.6, icon: "🍗"),
        NutritionEntry(name: "Yulaf Ezmesi (50g)", calories: 189, protein: 6.5, carbs: 33, fat: 3.5, icon: "🥣"),
        NutritionEntry(name: "Muz (Orta)", calories: 105, protein: 1.3, carbs: 27, fat: 0.3, icon: "🍌"),
        NutritionEntry(name: "Protein Tozu (1 ölçek)", calories: 120, protein: 24, carbs: 3, fat: 1, icon: "🥤"),
        NutritionEntry(name: "Pirinç Pilavı (100g)", calories: 130, protein: 2.7, carbs: 28, fat: 0.3, icon: "🍚"),
        NutritionEntry(name: "Somon (100g)", calories: 208, protein: 20, carbs: 0, fat: 13, icon: "🐟"),
        NutritionEntry(name: "Zeytinyağlı Salata", calories: 150, protein: 2, carbs: 10, fat: 12, icon: "🥗")
    ]
    
    private init() {
        loadData()
        resetDailyIfNeeded()
    }
    
    // MARK: - Günlük Hesaplamalar
    
    var dailyCalories: Double { entries.reduce(0) { $0 + $1.calories } }
    var dailyProtein: Double { entries.reduce(0) { $0 + $1.protein } }
    var dailyCarbs: Double { entries.reduce(0) { $0 + $1.carbs } }
    var dailyFat: Double { entries.reduce(0) { $0 + $1.fat } }
    
    // MARK: - İşlemler
    
    func addEntry(_ entry: NutritionEntry) {
        entries.insert(entry, at: 0)
        saveData()
    }
    
    func deleteEntry(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        saveData()
    }
    
    func updateWater(_ count: Int) {
        waterGlasses = max(0, min(count, 15))
        saveData()
    }
    
    // MARK: - Persistence
    
    private func resetDailyIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())
        let savedDate = UserDefaults.standard.object(forKey: lastDateKey) as? Date ?? .distantPast
        
        if Calendar.current.startOfDay(for: savedDate) != today {
            // Yeni gün, sadece su ve günlük yemekleri sıfırla. 
            // (Geçmişleri log'da tutabiliriz ama şimdilik performansı basit tutmak için siliyoruz veya arşive atıyoruz.
            // Bu örnekte sadece bugünü gösterdiğimiz için siliyoruz.)
            entries = []
            waterGlasses = 0
            UserDefaults.standard.set(today, forKey: lastDateKey)
            saveData()
        }
    }
    
    private func saveData() {
        if let enc = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(enc, forKey: entriesKey)
        }
        if let encG = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encG, forKey: goalsKey)
        }
        UserDefaults.standard.set(waterGlasses, forKey: waterKey)
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([NutritionEntry].self, from: data) {
            entries = decoded
        }
        if let data = UserDefaults.standard.data(forKey: goalsKey),
           let decoded = try? JSONDecoder().decode(NutritionGoals.self, from: data) {
            goals = decoded
        }
        waterGlasses = UserDefaults.standard.integer(forKey: waterKey)
    }
}
