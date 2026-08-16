import SwiftUI
import Charts

struct NutritionView: View {
    @StateObject private var store = NutritionStore.shared
    @State private var showingAddFood = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection

                        // Kalori Özeti (Gauge)
                        calorieSummarySection

                        // Makro Halkaları
                        macroSection

                        // Su Takibi
                        waterSection

                        // Günlük Öğünler
                        mealsSection

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddFood) {
                AddFoodView(store: store, isPresented: $showingAddFood)
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Beslenme")
                .font(.largeTitle).fontWeight(.heavy).foregroundColor(.white)
            Text("Bugün vücuduna ne kadar iyi baktın?")
                .font(.subheadline).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 20)
    }

    // MARK: - Kalori Özeti

    private var calorieSummarySection: some View {
        let progress = min(store.dailyCalories / store.goals.targetCalories, 1.0)
        let remaining = store.goals.targetCalories - store.dailyCalories

        return VStack(spacing: 16) {
            HStack {
                Image(systemName: "flame.fill").foregroundColor(.orange)
                Text("Günlük Kalori Hedefi").font(.headline).fontWeight(.bold).foregroundColor(.white)
                Spacer()
                Text("\(Int(store.goals.targetCalories)) kcal").font(.caption).foregroundColor(.gray)
            }

            ZStack {
                // Arka plan barı
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 24)

                    // İlerleme barı
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(0, geo.size.width * CGFloat(progress)), height: 24)
                        .animation(.spring(), value: progress)
                }
                .frame(height: 24)

                Text("\(Int(store.dailyCalories)) / \(Int(store.goals.targetCalories))")
                    .font(.caption).fontWeight(.bold)
                    .foregroundColor(.white)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Alınan").font(.caption2).foregroundColor(.gray)
                    Text("\(Int(store.dailyCalories))").font(.title3).fontWeight(.bold).foregroundColor(.white)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Kalan").font(.caption2).foregroundColor(.gray)
                    Text(remaining > 0 ? "\(Int(remaining))" : "Hedefe Ulaşıldı!")
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(remaining > 0 ? .green : .red)
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
        .padding(.horizontal)
    }

    // MARK: - Makro Halkaları

    private var macroSection: some View {
        HStack(spacing: 16) {
            MacroRing(title: "Protein", color: .cyan, current: store.dailyProtein, target: store.goals.targetProtein, unit: "g")
            MacroRing(title: "Karb", color: .purple, current: store.dailyCarbs, target: store.goals.targetCarbs, unit: "g")
            MacroRing(title: "Yağ", color: .yellow, current: store.dailyFat, target: store.goals.targetFat, unit: "g")
        }
        .padding(.horizontal)
    }

    // MARK: - Su Takibi

    private var waterSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "drop.fill").foregroundColor(.cyan)
                Text("Su Takibi").font(.headline).fontWeight(.bold).foregroundColor(.white)
                Spacer()
                Text("\(store.waterGlasses) / 8 Bardak").font(.caption).foregroundColor(.gray)
            }

            HStack(spacing: 8) {
                ForEach(0..<8, id: \.self) { index in
                    let isFilled = index < store.waterGlasses
                    Image(systemName: isFilled ? "drop.fill" : "drop")
                        .font(.title3)
                        .foregroundColor(isFilled ? .cyan : .gray.opacity(0.5))
                        .scaleEffect(isFilled ? 1.1 : 1.0)
                        .animation(.spring(), value: store.waterGlasses)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            store.updateWater(isFilled ? index : index + 1)
                        }
                }
            }
            .padding()
            .background(Color.cyan.opacity(0.1))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.cyan.opacity(0.3), lineWidth: 1))
        }
        .padding(18)
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
        .padding(.horizontal)
    }

    // MARK: - Günlük Öğünler

    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "fork.knife").foregroundColor(.green)
                Text("Bugün Tüketilenler").font(.headline).fontWeight(.bold).foregroundColor(.white)
                Spacer()
                Button(action: { showingAddFood = true }) {
                    Image(systemName: "plus.circle.fill").font(.title2).foregroundColor(.green)
                }
            }

            if store.entries.isEmpty {
                Text("Henüz bir öğün eklemedin.")
                    .font(.caption).foregroundColor(.gray)
                    .padding(.vertical, 10)
            } else {
                ForEach(store.entries) { entry in
                    HStack(spacing: 12) {
                        Text(entry.icon).font(.title)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.name).font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                            Text("\(Int(entry.protein))g P • \(Int(entry.carbs))g K • \(Int(entry.fat))g Y")
                                .font(.caption2).foregroundColor(.gray)
                        }

                        Spacer()

                        Text("\(Int(entry.calories)) kcal")
                            .font(.subheadline).fontWeight(.bold).foregroundColor(.green)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(12)
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
        .padding(.horizontal)
    }
}

// MARK: - Makro Halkası

struct MacroRing: View {
    let title: String
    let color: Color
    let current: Double
    let target: Double
    let unit: String

    var progress: Double { min(current / max(target, 1), 1.0) }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 70, height: 70)

                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(), value: progress)

                VStack(spacing: 2) {
                    Text("\(Int(current))").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(.white)
                    Text("/\(Int(target))").font(.system(size: 10)).foregroundColor(.gray)
                }
            }

            Text(title).font(.caption).fontWeight(.semibold).foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(16)
    }
}

// MARK: - Yemek Ekleme Sheet

struct AddFoodView: View {
    @ObservedObject var store: NutritionStore
    @Binding var isPresented: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)

                List {
                    Section(header: Text("Sık Tüketilenler")) {
                        ForEach(store.foodDatabase) { food in
                            Button(action: {
                                store.addEntry(food)
                                isPresented = false
                            }) {
                                HStack(spacing: 12) {
                                    Text(food.icon).font(.title2)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(food.name).font(.headline).foregroundColor(.primary)
                                        Text("\(Int(food.protein))g P • \(Int(food.carbs))g K • \(Int(food.fat))g Y")
                                            .font(.caption).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text("+\(Int(food.calories))").font(.subheadline).fontWeight(.bold).foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Yemek Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") { isPresented = false }
                }
            }
        }
    }
}
