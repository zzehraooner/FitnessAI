import SwiftUI
import UserNotifications

// MARK: - Planlayıcı Modeli

struct PlannedWorkout: Identifiable, Codable {
    var id = UUID()
    var routineTitle: String
    var routineIcon: String
    var weekday: Int          // 0=Pzt, 6=Paz
    var hour: Int             // 0-23
    var minute: Int           // 0/30
    var notificationEnabled: Bool
}

// MARK: - Planlayıcı Store

class WorkoutPlannerStore: ObservableObject {
    static let shared = WorkoutPlannerStore()
    @Published var plans: [PlannedWorkout] = []
    private let key = "workout_planner_plans"

    private init() { load() }

    func add(_ plan: PlannedWorkout) {
        plans.removeAll { $0.weekday == plan.weekday }
        plans.append(plan)
        plans.sort { $0.weekday < $1.weekday }
        save()
        if plan.notificationEnabled { scheduleNotification(for: plan) }
    }

    func remove(weekday: Int) {
        if let plan = plans.first(where: { $0.weekday == weekday }) {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["workout_\(plan.id)"])
        }
        plans.removeAll { $0.weekday == weekday }
        save()
    }

    private func scheduleNotification(for plan: PlannedWorkout) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }

            let content = UNMutableNotificationContent()
            content.title = "⏰ Antrenman Zamanı!"
            content.body = "\(plan.routineTitle) seni bekliyor. Haydi başla! 💪"
            content.sound = .default

            var components = DateComponents()
            components.weekday = plan.weekday + 2  // Pzt=2 iOS'ta
            components.hour   = plan.hour
            components.minute = plan.minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "workout_\(plan.id)", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    private func save() {
        if let enc = try? JSONEncoder().encode(plans) {
            UserDefaults.standard.set(enc, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([PlannedWorkout].self, from: data) else { return }
        plans = decoded
    }
}

// MARK: - WorkoutPlannerView

struct WorkoutPlannerView: View {
    @StateObject private var store = WorkoutPlannerStore.shared
    @State private var showingAddSheet = false
    @State private var selectedDay: Int? = nil

    private let weekdays = ["Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"]
    private let weekdayIcons = ["sun.and.horizon", "moon.fill", "sun.max.fill", "cloud.sun", "flame.fill", "star.fill", "heart.fill"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 24) {
                        // Başlık
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Haftalık Plan")
                                .font(.largeTitle).fontWeight(.heavy).foregroundColor(.white)
                            Text("Rutinlerini haftanın günlerine ata ve otomatik hatırlat.")
                                .font(.subheadline).foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)

                        // Haftalık Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            ForEach(weekdays.indices, id: \.self) { i in
                                DayPlanCard(
                                    day: weekdays[i],
                                    icon: weekdayIcons[i],
                                    plan: store.plans.first { $0.weekday == i },
                                    isToday: Calendar.current.component(.weekday, from: Date()) - 2 == i
                                )
                                .onTapGesture {
                                    selectedDay = i
                                    showingAddSheet = true
                                }
                            }
                        }
                        .padding(.horizontal)

                        // İstatistik
                        planStats

                        // İpuçları
                        tipsSection

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingAddSheet) {
            if let day = selectedDay {
                AddPlanSheet(weekday: day, dayName: weekdays[day], store: store, isPresented: $showingAddSheet)
            }
        }
    }

    // MARK: İstatistik

    private var planStats: some View {
        HStack(spacing: 12) {
            PlanStatChip(icon: "calendar.badge.checkmark",
                         value: "\(store.plans.count)/7",
                         label: "Planlanan Gün",
                         color: .cyan)
            PlanStatChip(icon: "bell.fill",
                         value: "\(store.plans.filter { $0.notificationEnabled }.count)",
                         label: "Bildirim Açık",
                         color: .orange)
            PlanStatChip(icon: "checkmark.circle.fill",
                         value: "\(store.plans.count > 0 ? Int(Double(store.plans.count)/7.0*100) : 0)%",
                         label: "Hafta Dolumu",
                         color: .green)
        }
        .padding(.horizontal)
    }

    // MARK: İpuçları

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill").foregroundColor(.yellow)
                Text("Planlama İpuçları").font(.headline).foregroundColor(.white)
            }

            ForEach([
                "Haftada en az 3 gün antrenman sürdürülebilir sonuç verir",
                "Yüksek yoğunluklu günlerin ardından dinlenme ekle",
                "Sabah antrenmanı metabolizmayı gün boyu aktif tutar"
            ], id: \.self) { tip in
                HStack(alignment: .top, spacing: 10) {
                    Circle().fill(Color.yellow).frame(width: 6, height: 6).padding(.top, 6)
                    Text(tip).font(.caption).foregroundColor(.gray)
                }
            }
        }
        .padding(18)
        .background(Color.yellow.opacity(0.06))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.yellow.opacity(0.2), lineWidth: 1))
        .padding(.horizontal)
    }
}

// MARK: - Gün Kartı

struct DayPlanCard: View {
    let day: String
    let icon: String
    let plan: PlannedWorkout?
    let isToday: Bool

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text(day)
                    .font(.caption).fontWeight(.bold)
                    .foregroundColor(isToday ? .cyan : .gray)
                Spacer()
                if isToday {
                    Text("Bugün")
                        .font(.system(size: 9)).fontWeight(.bold)
                        .foregroundColor(.cyan)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.cyan.opacity(0.2))
                        .cornerRadius(4)
                }
            }

            if let plan = plan {
                // Planlı gün
                VStack(spacing: 6) {
                    Image(systemName: plan.routineIcon)
                        .font(.title2)
                        .foregroundColor(.cyan)

                    Text(plan.routineTitle)
                        .font(.caption2).fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    Text(String(format: "%02d:%02d", plan.hour, plan.minute))
                        .font(.caption2).foregroundColor(.gray)

                    if plan.notificationEnabled {
                        Image(systemName: "bell.fill").font(.system(size: 10)).foregroundColor(.orange)
                    }
                }
            } else {
                // Boş gün
                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.title2).foregroundColor(.gray.opacity(0.4))
                    Text("+ Ekle")
                        .font(.caption2).foregroundColor(.gray.opacity(0.5))
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 110)
        .padding(14)
        .background(plan != nil ? Color.cyan.opacity(0.08) : Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(
            plan != nil ? Color.cyan.opacity(0.3) : (isToday ? Color.cyan.opacity(0.4) : Color.clear),
            lineWidth: 1)
        )
    }
}

// MARK: - Plan Ekle Sheet

struct AddPlanSheet: View {
    let weekday: Int
    let dayName: String
    @ObservedObject var store: WorkoutPlannerStore
    @Binding var isPresented: Bool

    @State private var selectedRoutine = "Tam Vücut Antrenmanı"
    @State private var selectedHour = 8
    @State private var selectedMinute = 0
    @State private var notifEnabled = true

    private let routines = [
        ("Tam Vücut Antrenmanı", "figure.strengthtraining.traditional"),
        ("HIIT Yakıcı", "bolt.fill"),
        ("Yoga Akışı", "figure.yoga"),
        ("Üst Vücut Günü", "figure.arms.open"),
        ("Bacak Günü", "figure.walk"),
        ("Kardio Blast", "heart.fill"),
        ("Çekirdek & Karın", "figure.core.training"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 24) {
                        // Rutin Seçimi
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rutin Seç").font(.headline).foregroundColor(.white)

                            ForEach(routines, id: \.0) { routine in
                                Button(action: { selectedRoutine = routine.0 }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: routine.1)
                                            .font(.title3)
                                            .foregroundColor(selectedRoutine == routine.0 ? .cyan : .gray)
                                            .frame(width: 30)

                                        Text(routine.0)
                                            .font(.subheadline).fontWeight(.medium)
                                            .foregroundColor(selectedRoutine == routine.0 ? .white : .gray)

                                        Spacer()

                                        if selectedRoutine == routine.0 {
                                            Image(systemName: "checkmark.circle.fill").foregroundColor(.cyan)
                                        }
                                    }
                                    .padding(14)
                                    .background(selectedRoutine == routine.0 ? Color.cyan.opacity(0.12) : Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                                        selectedRoutine == routine.0 ? Color.cyan.opacity(0.4) : Color.clear, lineWidth: 1))
                                }
                            }
                        }
                        .padding(.horizontal)

                        // Saat Seçimi
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Antrenman Saati").font(.headline).foregroundColor(.white)

                            HStack(spacing: 0) {
                                Picker("Saat", selection: $selectedHour) {
                                    ForEach(5..<24) { h in
                                        Text(String(format: "%02d", h)).tag(h)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 100, height: 120)
                                .clipped()

                                Text(":").font(.title).foregroundColor(.white)

                                Picker("Dakika", selection: $selectedMinute) {
                                    Text("00").tag(0)
                                    Text("15").tag(15)
                                    Text("30").tag(30)
                                    Text("45").tag(45)
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 100, height: 120)
                                .clipped()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal)

                        // Bildirim Toggle
                        HStack {
                            Image(systemName: "bell.fill").foregroundColor(.orange)
                            Text("Hatırlatıcı Kur").font(.subheadline).fontWeight(.medium).foregroundColor(.white)
                            Spacer()
                            Toggle("", isOn: $notifEnabled).tint(.orange)
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(14)
                        .padding(.horizontal)

                        // Kaydet Butonu
                        Button(action: savePlan) {
                            Label("Planı Kaydet", systemImage: "calendar.badge.plus")
                                .font(.headline).fontWeight(.bold)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.cyan)
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("\(dayName) Planı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("İptal") { isPresented = false }
                        .foregroundColor(.gray)
                }
                if store.plans.first(where: { $0.weekday == weekday }) != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Sil") {
                            store.remove(weekday: weekday)
                            isPresented = false
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
    }

    private func savePlan() {
        let icon = routines.first { $0.0 == selectedRoutine }?.1 ?? "figure.run"
        let plan = PlannedWorkout(
            routineTitle: selectedRoutine,
            routineIcon: icon,
            weekday: weekday,
            hour: selectedHour,
            minute: selectedMinute,
            notificationEnabled: notifEnabled
        )
        store.add(plan)
        isPresented = false
    }
}

// MARK: - Alt Bileşen

struct PlanStatChip: View {
    let icon: String; let value: String; let label: String; let color: Color
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: icon).foregroundColor(color).font(.title3)
            Text(value).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
            Text(label).font(.caption2).foregroundColor(.gray).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.1))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.25), lineWidth: 1))
    }
}
