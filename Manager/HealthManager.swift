import Foundation
import HealthKit
import Combine

class HealthManager: ObservableObject {
    let healthStore = HKHealthStore()
    
    @Published var dailySteps: Double = 0
    @Published var runningMinutes: Double = 0
    @Published var caloriesBurned: Double = 0
    @Published var heartRate: Double = 0
    
    // Grafik için son 7 günün adım verileri (Basit bir struct kullanıyoruz)
    struct StepData: Identifiable {
        let id = UUID()
        let day: String
        let steps: Double
    }
    @Published var weeklySteps: [StepData] = []
    
    init() {
        requestAuthorization()
        
        // Haftalık adımları HealthKit üzerinden çekeceğiz.
        weeklySteps = []
    }
    
    func requestAuthorization() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        let typesToRead: Set = [stepType, exerciseType, energyType, heartRateType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if success {
                self.fetchDailySteps()
                self.fetchExerciseTime()
                self.fetchCaloriesBurned()
                self.fetchWeeklySteps()
                self.startHeartRateQuery()
            } else {
                print("HealthKit izni alınamadı. Hata: \(error?.localizedDescription ?? "Bilinmeyen Hata")")
            }
        }
    }
    
    func fetchDailySteps() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            DispatchQueue.main.async {
                self.dailySteps = sum.doubleValue(for: HKUnit.count())
            }
        }
        healthStore.execute(query)
    }
    
    func fetchExerciseTime() {
        let exerciseType = HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: exerciseType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            DispatchQueue.main.async {
                self.runningMinutes = sum.doubleValue(for: HKUnit.minute())
            }
        }
        healthStore.execute(query)
    }
    
    func fetchCaloriesBurned() {
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            guard let result = result, let sum = result.sumQuantity() else { return }
            DispatchQueue.main.async {
                self.caloriesBurned = sum.doubleValue(for: HKUnit.kilocalorie())
            }
        }
        healthStore.execute(query)
    }
    
    // Son 7 günün adım sayısını gün gün çek
    func fetchWeeklySteps() {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let calendar = Calendar.current
        let now = Date()
        
        // Son 7 gün için başlangıç tarihi
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) else { return }
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
        
        var interval = DateComponents()
        interval.day = 1
        
        let query = HKStatisticsCollectionQuery(quantityType: stepType,
                                                quantitySamplePredicate: predicate,
                                                options: .cumulativeSum,
                                                anchorDate: startDate,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = { _, result, _ in
            guard let result = result else { return }
            
            var fetchedSteps: [StepData] = []
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "tr_TR")
            dateFormatter.dateFormat = "EEE" // Pzt, Sal, vb.
            
            result.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                if let sum = statistics.sumQuantity() {
                    let steps = sum.doubleValue(for: HKUnit.count())
                    let dayString = dateFormatter.string(from: statistics.startDate)
                    fetchedSteps.append(StepData(day: dayString, steps: steps))
                } else {
                    let dayString = dateFormatter.string(from: statistics.startDate)
                    fetchedSteps.append(StepData(day: dayString, steps: 0))
                }
            }
            
            DispatchQueue.main.async {
                self.weeklySteps = fetchedSteps
            }
        }
        
        healthStore.execute(query)
    }
    
    // Nabız verisini anlık dinlemek için bir Observer Query
    func startHeartRateQuery() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, completionHandler, error in
            if error != nil { return }
            self?.fetchLatestHeartRate()
            completionHandler()
        }
        healthStore.execute(query)
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { _, _ in }
    }
    
    private func fetchLatestHeartRate() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else { return }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, samples, _ in
            guard let sample = samples?.first as? HKQuantitySample else { return }
            
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let value = sample.quantity.doubleValue(for: heartRateUnit)
            
            DispatchQueue.main.async {
                self.heartRate = value
            }
        }
        healthStore.execute(query)
    }
}
