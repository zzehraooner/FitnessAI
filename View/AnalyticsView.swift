import SwiftUI
import Charts

struct AnalyticsView: View {
    @StateObject var viewModel = AnalyticsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // MARK: — Başlık
                        Text("Analizler")
                            .font(.largeTitle).fontWeight(.heavy).foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.top, 20)

                        // MARK: — Özet Chip'leri
                        overviewSection

                        // MARK: — Vücut Analizi (Heatmap) Linki
                        NavigationLink(destination: MuscleHeatmapView()) {
                            HStack {
                                Image(systemName: "figure.arms.open")
                                    .foregroundColor(.purple)
                                    .font(.title2)
                                VStack(alignment: .leading) {
                                    Text("Detaylı Vücut Analizi")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Kas grupları ve ısı haritasını gör")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.purple.opacity(0.15))
                            .cornerRadius(15)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.purple.opacity(0.3), lineWidth: 1))
                        }
                        .padding(.horizontal)

                        // MARK: — Streak
                        streakSection

                        // MARK: — Haftalık Tekrar Grafiği
                        if !viewModel.dailyReps.isEmpty {
                            chartSection(
                                title: "Haftalık Tekrar",
                                subtitle: "Son 7 gün",
                                icon: "chart.bar.fill",
                                iconColor: .cyan
                            ) {
                                Chart(viewModel.dailyReps, id: \.date) { point in
                                    BarMark(
                                        x: .value("Gün", point.date, unit: .day),
                                        y: .value("Tekrar", point.count)
                                    )
                                    .foregroundStyle(LinearGradient(colors: [.cyan, .blue], startPoint: .bottom, endPoint: .top))
                                    .cornerRadius(4)
                                }
                                .frame(height: 150)
                                .chartXAxis {
                                    AxisMarks(values: .stride(by: .day)) { value in
                                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                                            .foregroundStyle(Color.gray)
                                    }
                                }
                                .chartYAxis {
                                    AxisMarks { value in
                                        AxisValueLabel().foregroundStyle(Color.gray)
                                    }
                                }
                            }
                        }

                        // MARK: — Form Doğruluğu Grafiği
                        if !viewModel.formProgressSeries.isEmpty {
                            chartSection(
                                title: "Form Doğruluğu",
                                subtitle: "Son 14 seans",
                                icon: "figure.arms.open",
                                iconColor: .green
                            ) {
                                Chart(viewModel.formProgressSeries.enumerated().map { ($0.offset, $0.element) }, id: \.0) { idx, session in
                                    LineMark(
                                        x: .value("Seans", idx + 1),
                                        y: .value("Form %", session.averageFormPercentage)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(Color.green)
                                    .lineStyle(StrokeStyle(lineWidth: 2.5))

                                    AreaMark(
                                        x: .value("Seans", idx + 1),
                                        y: .value("Form %", session.averageFormPercentage)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(LinearGradient(
                                        colors: [Color.green.opacity(0.4), Color.green.opacity(0)],
                                        startPoint: .top, endPoint: .bottom
                                    ))
                                }
                                .frame(height: 140)
                                .chartYScale(domain: 0...100)
                                .chartYAxis {
                                    AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                                        AxisValueLabel().foregroundStyle(Color.gray)
                                    }
                                }
                                .chartXAxis(.hidden)
                            }
                        }

                        // MARK: — Egzersiz Dağılımı
                        if !viewModel.exerciseDistribution.isEmpty {
                            chartSection(
                                title: "Egzersiz Dağılımı",
                                subtitle: "Toplam tekrara göre",
                                icon: "chart.pie.fill",
                                iconColor: .orange
                            ) {
                                Chart(viewModel.exerciseDistribution, id: \.name) { item in
                                    SectorMark(
                                        angle: .value("Tekrar", item.count),
                                        innerRadius: .ratio(0.55),
                                        angularInset: 2
                                    )
                                    .foregroundStyle(by: .value("Egzersiz", item.name))
                                    .cornerRadius(4)
                                }
                                .frame(height: 220)
                                .chartLegend(position: .bottom, alignment: .center) {
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 8) {
                                        ForEach(viewModel.exerciseDistribution.prefix(6), id: \.name) { item in
                                            HStack(spacing: 5) {
                                                Circle().fill(exerciseColor(item.name)).frame(width: 8)
                                                Text(item.name).font(.caption2).foregroundColor(.gray)
                                            }
                                        }
                                    }
                                    .padding(.top, 8)
                                }
                            }
                        }

                        // MARK: — Geçmiş Seans Listesi
                        if !viewModel.workoutSessions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                sectionHeader(title: "Geçmiş Seanslar", icon: "clock.fill", iconColor: .yellow)

                                ForEach(viewModel.workoutSessions.prefix(5)) { session in
                                    SessionRow(session: session)
                                }
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Overview Section

    private var overviewSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                StatChip(icon: "figure.run", value: "\(viewModel.totalSessions)", label: "Seans", color: .cyan)
                StatChip(icon: "repeat.circle.fill", value: "\(viewModel.totalReps)", label: "Toplam Tekrar", color: .orange)
                StatChip(icon: "clock.fill", value: String(format: "%.0f", viewModel.totalMinutes), label: "Dakika", color: .purple)
                StatChip(icon: "brain.head.profile", value: viewModel.mostFrequentExercise, label: "En Sık", color: .green)
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Streak Section

    private var streakSection: some View {
        HStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.system(size: 40))
                .foregroundStyle(LinearGradient(colors: [.yellow, .orange, .red], startPoint: .top, endPoint: .bottom))

            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.currentStreak) Günlük Seri")
                    .font(.title2).fontWeight(.heavy).foregroundColor(.white)
                Text("Art arda antrenman yaptığınız gün sayısı")
                    .font(.caption).foregroundColor(.gray)
            }

            Spacer()

            if let best = viewModel.bestFormSession {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("En İyi Form")
                        .font(.caption2).foregroundColor(.gray)
                    Text(String(format: "%.0f%%", best.averageFormPercentage))
                        .font(.title3).fontWeight(.bold).foregroundColor(.green)
                    Text(best.exerciseName)
                        .font(.caption2).foregroundColor(.gray)
                }
            }
        }
        .padding(18)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.orange.opacity(0.4), lineWidth: 1))
        .padding(.horizontal)
    }

    // MARK: - Chart Section Builder

    private func chartSection<Content: View>(
        title: String,
        subtitle: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader(title: title, subtitle: subtitle, icon: icon, iconColor: iconColor)
            content()
        }
        .padding(18)
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
        .padding(.horizontal)
    }

    private func sectionHeader(title: String, subtitle: String? = nil, icon: String, iconColor: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(iconColor).font(.headline)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline).fontWeight(.bold).foregroundColor(.white)
                if let sub = subtitle {
                    Text(sub).font(.caption2).foregroundColor(.gray)
                }
            }
        }
    }

    // Egzersiz rengi (pasta grafikte)
    private func exerciseColor(_ name: String) -> Color {
        let colors: [Color] = [.cyan, .orange, .green, .purple, .yellow, .pink]
        let hash = abs(name.hashValue) % colors.count
        return colors[hash]
    }
}

// MARK: - Alt Bileşenler

struct StatChip: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).font(.title3).foregroundColor(color)
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1).minimumScaleFactor(0.6)
            Text(label)
                .font(.caption2).foregroundColor(.gray)
        }
        .frame(width: 90, height: 80)
        .background(color.opacity(0.12))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.3), lineWidth: 1))
    }
}

struct SessionRow: View {
    let session: WorkoutSession

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(formColor.opacity(0.25))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(format: "%.0f%%", session.averageFormPercentage))
                        .font(.caption).fontWeight(.bold).foregroundColor(formColor)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(session.exerciseName)
                    .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                Text("\(session.totalReps) tekrar · \(session.durationSeconds / 60) dk")
                    .font(.caption2).foregroundColor(.gray)
            }

            Spacer()

            Text(session.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2).foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }

    private var formColor: Color {
        session.averageFormPercentage >= 90 ? .green :
        session.averageFormPercentage >= 70 ? .yellow : .orange
    }
}


