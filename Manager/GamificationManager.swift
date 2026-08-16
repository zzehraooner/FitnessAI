import Foundation
import Combine
import SwiftUI

// MARK: - Günlük Görev Modeli

struct DailyGoal: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let xpReward: Int
    let targetValue: Int
    var currentValue: Int
    var isCompleted: Bool { currentValue >= targetValue }

    var progress: Double { min(Double(currentValue) / Double(targetValue), 1.0) }
}

// MARK: - Gamification Manager

class GamificationManager: ObservableObject {
    static let shared = GamificationManager()

    // MARK: Published State
    @Published var totalXP: Int = 0
    @Published var unlockedBadges: [String] = []
    @Published var dailyGoals: [DailyGoal] = []
    @Published var pendingBadge: Badge? = nil       // Yeni kazanılan rozet (popup için)
    @Published var pendingXPGain: Int = 0           // Animasyon için XP artışı

    // MARK: Level Hesaplama
    /// Her level 300 XP gerektirir, üstel zorluk
    var level: Int {
        max(1, Int(sqrt(Double(totalXP) / 100)) + 1)
    }

    var xpForCurrentLevel: Int { (level - 1) * (level - 1) * 100 }
    var xpForNextLevel: Int    { level * level * 100 }
    var levelProgress: Double  {
        let range = xpForNextLevel - xpForCurrentLevel
        guard range > 0 else { return 1.0 }
        return Double(totalXP - xpForCurrentLevel) / Double(range)
    }
    var levelTitle: String {
        switch level {
        case 1: return "Acemi"
        case 2: return "Başlangıç"
        case 3: return "Amatör"
        case 4...5: return "Tutkulu"
        case 6...8: return "Atlet"
        case 9...11: return "Elit"
        case 12...15: return "Şampiyon"
        default: return "Efsane"
        }
    }

    // MARK: Tüm Rozetler (20+)
    let allBadges: [Badge] = [
        // Tekrar rozetleri
        Badge(id: "first_blood",       name: "İlk Kan",         iconName: "drop.fill",                  description: "İlk 10 tekrarını tamamla",       requiredReps: 10),
        Badge(id: "bronze_warrior",    name: "Bronz Savaşçı",   iconName: "medal.fill",                 description: "50 tekrar yap",                  requiredReps: 50),
        Badge(id: "silver_knight",     name: "Gümüş Şövalye",   iconName: "shield.fill",                description: "100 tekrar yap",                 requiredReps: 100),
        Badge(id: "iron_legs",         name: "Demir Bacak",     iconName: "figure.walk",                description: "250 tekrar yap",                 requiredReps: 250),
        Badge(id: "golden_god",        name: "Altın Tanrı",     iconName: "crown.fill",                 description: "500 tekrar yap",                 requiredReps: 500),
        Badge(id: "fitness_monster",   name: "Fitness Canavarı",iconName: "flame.fill",                 description: "1000 tekrar yap",                requiredReps: 1000),
        Badge(id: "rep_machine",       name: "Tekrar Makinesi", iconName: "repeat.circle.fill",         description: "2500 tekrar yap",                requiredReps: 2500),
        Badge(id: "legend",            name: "Efsane",          iconName: "star.fill",                  description: "5000 tekrar — Gerçek bir efsane!", requiredReps: 5000),
        // Form rozetleri
        Badge(id: "perfect_form",      name: "Mükemmel Form",   iconName: "figure.arms.open",           description: "Bir seansta %95+ form yüzdesi al", requiredReps: 0),
        Badge(id: "form_master",       name: "Form Ustası",     iconName: "checkmark.seal.fill",        description: "5 farklı seansta %90+ form al",   requiredReps: 0),
        // Streak rozetleri
        Badge(id: "week_warrior",      name: "Hafta Savaşçısı", iconName: "calendar.badge.checkmark",   description: "7 gün üst üste antrenman yap",    requiredReps: 0),
        Badge(id: "month_champion",    name: "Ay Şampiyonu",    iconName: "rosette",                    description: "30 gün seri kır",                  requiredReps: 0),
        // Çeşitlilik rozetleri
        Badge(id: "all_rounder",       name: "Her Şeyi Dener",  iconName: "sparkles",                   description: "5 farklı egzersiz türü dene",     requiredReps: 0),
        Badge(id: "yoga_master",       name: "Yoga Ustası",     iconName: "figure.yoga",                description: "10 yoga seansı tamamla",          requiredReps: 0),
        Badge(id: "speed_demon",       name: "Hız Şeytanı",     iconName: "bolt.fill",                  description: "HIIT rutini tamamla",             requiredReps: 0),
        // XP/Level rozetleri
        Badge(id: "level5",            name: "Seviye 5",        iconName: "5.circle.fill",              description: "5. seviyeye ulaş",                requiredReps: 0),
        Badge(id: "level10",           name: "Onluk Kulübü",    iconName: "10.circle.fill",             description: "10. seviyeye ulaş",               requiredReps: 0),
        // Özel
        Badge(id: "early_bird",        name: "Erken Kuş",       iconName: "sunrise.fill",               description: "Sabah 7'den önce antrenman yap",  requiredReps: 0),
        Badge(id: "night_owl",         name: "Gece Kuşu",       iconName: "moon.stars.fill",            description: "Gece 22'den sonra antrenman yap", requiredReps: 0),
        Badge(id: "centurion",         name: "Yüzbaşı",         iconName: "100.circle.fill",            description: "100 seans tamamla",               requiredReps: 0),
    ]

    // MARK: Keys
    private let xpKey       = "gamification_xp"
    private let badgesKey   = "gamification_badges"
    private let goalsKey    = "gamification_goals"
    private let goalDateKey = "gamification_goals_date"

    private init() {
        loadData()
        refreshDailyGoalsIfNeeded()
    }

    // MARK: - XP Ekleme

    func addXP(_ amount: Int, reason: String = "") {
        totalXP += amount
        pendingXPGain = amount
        saveData()
        checkLevelBadges()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // MARK: - Seans Tamamlandığında

    func onSessionCompleted(reps: Int, formPercentage: Double, exerciseName: String, durationMinutes: Int, routineTitle: String) {
        let xpEarned = reps + (durationMinutes * 5) + (formPercentage > 90 ? 25 : formPercentage > 75 ? 10 : 0)
        addXP(Int(xpEarned))
        checkRepBadges(newTotalReps: SessionStore.shared.totalReps)
        checkFormBadges(formPct: formPercentage)
        checkStreakBadges()
        checkDiversityBadges()
        checkTimeBadges()
        checkSessionCountBadges()
        updateDailyGoals(reps: reps, exerciseName: exerciseName)

        // Sesli bildirim
        if let badge = pendingBadge {
            SpeechManager.shared.speak("Tebrikler! \(badge.name) rozetini kazandınız!", force: true)
        }
    }

    // MARK: - Badge Kontrolleri

    private func checkRepBadges(newTotalReps: Int) {
        for badge in allBadges where badge.requiredReps > 0 {
            unlockIfNeeded(badge, condition: newTotalReps >= badge.requiredReps)
        }
    }

    private func checkFormBadges(formPct: Double) {
        unlockIfNeeded(find("perfect_form"), condition: formPct >= 95)
        let highFormSessions = SessionStore.shared.sessions.filter { $0.averageFormPercentage >= 90 }.count
        unlockIfNeeded(find("form_master"), condition: highFormSessions >= 5)
    }

    private func checkStreakBadges() {
        let streak = SessionStore.shared.currentStreak
        unlockIfNeeded(find("week_warrior"),   condition: streak >= 7)
        unlockIfNeeded(find("month_champion"), condition: streak >= 30)
    }

    private func checkDiversityBadges() {
        let uniqueExercises = Set(SessionStore.shared.sessions.map { $0.exerciseName }).count
        unlockIfNeeded(find("all_rounder"), condition: uniqueExercises >= 5)

        let yogaSessions = SessionStore.shared.sessions.filter {
            $0.exerciseName.lowercased().contains("yoga") ||
            $0.exerciseName.lowercased().contains("pose") ||
            $0.routineTitle?.lowercased().contains("yoga") == true
        }.count
        unlockIfNeeded(find("yoga_master"), condition: yogaSessions >= 10)

        let hiitSessions = SessionStore.shared.sessions.filter {
            $0.routineTitle?.lowercased().contains("hiit") == true
        }.count
        unlockIfNeeded(find("speed_demon"), condition: hiitSessions >= 1)
    }

    private func checkLevelBadges() {
        unlockIfNeeded(find("level5"),  condition: level >= 5)
        unlockIfNeeded(find("level10"), condition: level >= 10)
    }

    private func checkTimeBadges() {
        let hour = Calendar.current.component(.hour, from: Date())
        unlockIfNeeded(find("early_bird"), condition: hour < 7)
        unlockIfNeeded(find("night_owl"),  condition: hour >= 22)
    }

    private func checkSessionCountBadges() {
        unlockIfNeeded(find("centurion"), condition: SessionStore.shared.totalSessions >= 100)
    }

    private func unlockIfNeeded(_ badge: Badge?, condition: Bool) {
        guard let badge = badge, condition, !unlockedBadges.contains(badge.id) else { return }
        unlockedBadges.append(badge.id)
        pendingBadge = badge
        addXP(50) // Rozet bonusu
        saveData()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func find(_ id: String) -> Badge? {
        allBadges.first { $0.id == id }
    }

    // MARK: - Günlük Görevler

    private func refreshDailyGoalsIfNeeded() {
        let today = Calendar.current.startOfDay(for: Date())
        if let savedDate = UserDefaults.standard.object(forKey: goalDateKey) as? Date,
           Calendar.current.startOfDay(for: savedDate) == today,
           let data = UserDefaults.standard.data(forKey: goalsKey),
           let saved = try? JSONDecoder().decode([DailyGoal].self, from: data) {
            dailyGoals = saved
        } else {
            dailyGoals = generateDailyGoals()
            UserDefaults.standard.set(Date(), forKey: goalDateKey)
            saveGoals()
        }
    }

    private func generateDailyGoals() -> [DailyGoal] {
        [
            DailyGoal(id: "daily_reps",    title: "50 Tekrar",        description: "Bugün toplam 50 tekrar yap",        icon: "repeat.circle.fill",   xpReward: 30, targetValue: 50,  currentValue: 0),
            DailyGoal(id: "daily_session", title: "1 Seans",           description: "En az 1 seans tamamla",            icon: "play.circle.fill",     xpReward: 50, targetValue: 1,   currentValue: 0),
            DailyGoal(id: "daily_form",    title: "%80 Form",          description: "Seansını %80+ form ile bitir",     icon: "figure.arms.open",     xpReward: 40, targetValue: 80,  currentValue: 0),
            DailyGoal(id: "daily_min",     title: "10 Dakika",         description: "10 dakika antrenman yap",          icon: "timer",                xpReward: 25, targetValue: 10,  currentValue: 0),
            DailyGoal(id: "daily_streak",  title: "Seriyi Koru",       description: "Bugün antrenman yap ve seriyi koru",icon: "flame.fill",          xpReward: 60, targetValue: 1,   currentValue: 0),
        ]
    }

    func updateDailyGoals(reps: Int, exerciseName: String) {
        for i in dailyGoals.indices {
            let wasCompleted = dailyGoals[i].isCompleted
            switch dailyGoals[i].id {
            case "daily_reps":    dailyGoals[i].currentValue += reps
            case "daily_session": dailyGoals[i].currentValue += 1
            case "daily_streak":  dailyGoals[i].currentValue  = 1
            case "daily_min":     dailyGoals[i].currentValue += max(1, reps / 5)
            default: break
            }
            if !wasCompleted && dailyGoals[i].isCompleted {
                addXP(dailyGoals[i].xpReward)
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
        saveGoals()
    }

    func updateFormGoal(formPct: Double) {
        for i in dailyGoals.indices where dailyGoals[i].id == "daily_form" {
            dailyGoals[i].currentValue = max(dailyGoals[i].currentValue, Int(formPct))
        }
        saveGoals()
    }

    // MARK: - Persistence

    private func saveData() {
        UserDefaults.standard.set(totalXP,         forKey: xpKey)
        UserDefaults.standard.set(unlockedBadges,  forKey: badgesKey)
    }

    private func loadData() {
        totalXP        = UserDefaults.standard.integer(forKey: xpKey)
        unlockedBadges = UserDefaults.standard.stringArray(forKey: badgesKey) ?? []
    }

    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(dailyGoals) {
            UserDefaults.standard.set(encoded, forKey: goalsKey)
        }
    }
}
