import SwiftUI
import Charts

struct MuscleHeatmapView: View {
    @ObservedObject private var store = SessionStore.shared

    // MARK: Hesaplamalar

    private var muscleIntensity: [MuscleGroup: Double] {
        var dict = [MuscleGroup: Int]()
        for session in store.sessions {
            // ExerciseType'ı isimden bul
            guard let exType = ExerciseType.allCases.first(where: { $0.rawValue == session.exerciseName })
            else { continue }
            for muscle in exType.primaryMuscles {
                dict[muscle, default: 0] += session.totalReps
            }
        }
        let maxVal = dict.values.max() ?? 1
        return dict.mapValues { Double($0) / Double(maxVal) }
    }

    private var jointRiskData: [(exercise: String, risk: Int)] {
        store.exerciseDistribution.prefix(8).compactMap { item in
            guard let ex = ExerciseType.allCases.first(where: { $0.rawValue == item.name }) else { return nil }
            return (exercise: item.name, risk: ex.jointStressLevel)
        }
    }

    private var asymmetryScore: Double {
        // Sol-sağ kaslar arasındaki denge (örnek hesaplama)
        let left  = (muscleIntensity[.legs] ?? 0) + (muscleIntensity[.arms] ?? 0)
        let right = (muscleIntensity[.chest] ?? 0) + (muscleIntensity[.back] ?? 0)
        let total = left + right
        guard total > 0 else { return 0 }
        return min(abs(left - right) / total * 100, 100)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 24) {
                        header
                        bodyHeatmap
                        asymmetrySection
                        jointRiskChart
                        muscleBalanceList
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Başlık

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Vücut Analizi")
                .font(.largeTitle).fontWeight(.heavy).foregroundColor(.white)
            Text("Kas gruplarına göre antrenman yoğunluğun")
                .font(.subheadline).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    // MARK: - Vücut Isı Haritası (SwiftUI Çizimi)

    private var bodyHeatmap: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Kas Yoğunluk Haritası", icon: "figure.arms.open", color: .orange)

            HStack(alignment: .top, spacing: 20) {
                // Ön Vücut
                VStack(spacing: 6) {
                    Text("Ön").font(.caption2).foregroundColor(.gray)
                    BodyFrontView(intensity: muscleIntensity)
                        .frame(width: 140, height: 260)
                }

                // Arka Vücut
                VStack(spacing: 6) {
                    Text("Arka").font(.caption2).foregroundColor(.gray)
                    BodyBackView(intensity: muscleIntensity)
                        .frame(width: 140, height: 260)
                }
            }
            .frame(maxWidth: .infinity)

            // Renk Lejandı
            HStack(spacing: 4) {
                ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                    if let intensity = muscleIntensity[muscle], intensity > 0 {
                        HStack(spacing: 3) {
                            Circle().fill(muscle.color).frame(width: 8)
                            Text(muscle.rawValue).font(.system(size: 9)).foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
        .padding(.horizontal)
    }

    // MARK: - Asimetri

    private var asymmetrySection: some View {
        let score = asymmetryScore
        let label = score < 15 ? "Mükemmel Denge" : score < 30 ? "İyi Denge" : "Dengesizlik Var"
        let color: Color = score < 15 ? .green : score < 30 ? .yellow : .red

        return HStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 70, height: 70)
                Circle()
                    .trim(from: 0, to: CGFloat(1 - score / 100))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                Text(String(format: "%.0f%%", 100 - score))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Kas Dengesi").font(.headline).fontWeight(.bold).foregroundColor(.white)
                Text(label).font(.subheadline).foregroundColor(color)
                Text("Önerilen: Zayıf kas gruplarına odaklan")
                    .font(.caption2).foregroundColor(.gray)
            }

            Spacer()
        }
        .padding(18)
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
        .padding(.horizontal)
    }

    // MARK: - Eklem Risk Grafiği

    private var jointRiskChart: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Eklem Yük Skoru", icon: "waveform.path.ecg", color: .red)

            if jointRiskData.isEmpty {
                Text("Henüz yeterli veri yok").font(.caption).foregroundColor(.gray)
            } else {
                Chart(jointRiskData, id: \.exercise) { item in
                    BarMark(
                        x: .value("Egzersiz", String(item.exercise.prefix(8))),
                        y: .value("Risk", item.risk)
                    )
                    .foregroundStyle(riskColor(item.risk))
                    .cornerRadius(4)
                }
                .frame(height: 120)
                .chartYScale(domain: 0...5)
                .chartYAxis {
                    AxisMarks(values: [0,1,2,3,4,5]) { v in
                        AxisValueLabel().foregroundStyle(Color.gray)
                    }
                }
                .chartXAxis {
                    AxisMarks { _ in AxisValueLabel().foregroundStyle(Color.gray) }
                }

                HStack(spacing: 16) {
                    ForEach([(1, Color.green, "Düşük"), (3, Color.yellow, "Orta"), (5, Color.red, "Yüksek")], id: \.0) { (n, c, l) in
                        HStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 3).fill(c).frame(width: 12, height: 8)
                            Text(l).font(.caption2).foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
        .padding(.horizontal)
    }

    // MARK: - Kas Grubu Listesi

    private var muscleBalanceList: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Kas Grubu Dağılımı", icon: "chart.bar.fill", color: .purple)

            ForEach(MuscleGroup.allCases, id: \.self) { muscle in
                let intensity = muscleIntensity[muscle] ?? 0
                MuscleRow(muscle: muscle, intensity: intensity)
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.06))
        .cornerRadius(18)
        .padding(.horizontal)
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(color)
            Text(title).font(.headline).fontWeight(.bold).foregroundColor(.white)
        }
    }

    private func riskColor(_ level: Int) -> Color {
        level <= 2 ? .green : level == 3 ? .yellow : .red
    }
}

// MARK: - Kas Grubu Satırı

struct MuscleRow: View {
    let muscle: MuscleGroup
    let intensity: Double

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: muscle.icon)
                .font(.title3)
                .foregroundColor(muscle.color)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(muscle.rawValue).font(.subheadline).fontWeight(.medium).foregroundColor(.white)
                    Spacer()
                    Text(String(format: "%.0f%%", intensity * 100))
                        .font(.caption).fontWeight(.bold)
                        .foregroundColor(intensity > 0.6 ? muscle.color : .gray)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4).fill(Color.white.opacity(0.08)).frame(height: 6)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(muscle.color)
                            .frame(width: geo.size.width * CGFloat(intensity), height: 6)
                            .animation(.spring(), value: intensity)
                    }
                }
                .frame(height: 6)
            }
        }
    }
}

// MARK: - Ön Vücut SVG (SwiftUI Path)

struct BodyFrontView: View {
    let intensity: [MuscleGroup: Double]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Baş
                Ellipse()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: w * 0.35, height: h * 0.14)
                    .position(x: w * 0.5, y: h * 0.07)

                // Göğüs
                bodyPart(.chest, w: w, h: h,
                         rect: CGRect(x: w*0.2, y: h*0.18, width: w*0.6, height: h*0.14))

                // Karın (Core)
                bodyPart(.core, w: w, h: h,
                         rect: CGRect(x: w*0.25, y: h*0.32, width: w*0.5, height: h*0.14))

                // Kollar (ikisi)
                bodyPart(.arms, w: w, h: h,
                         rect: CGRect(x: w*0.03, y: h*0.18, width: w*0.17, height: h*0.30))
                bodyPart(.arms, w: w, h: h,
                         rect: CGRect(x: w*0.80, y: h*0.18, width: w*0.17, height: h*0.30))

                // Bacaklar
                bodyPart(.legs, w: w, h: h,
                         rect: CGRect(x: w*0.23, y: h*0.56, width: w*0.22, height: h*0.38))
                bodyPart(.legs, w: w, h: h,
                         rect: CGRect(x: w*0.55, y: h*0.56, width: w*0.22, height: h*0.38))
            }
        }
    }

    private func bodyPart(_ muscle: MuscleGroup, w: CGFloat, h: CGFloat, rect: CGRect) -> some View {
        let intensity = max(intensity[muscle] ?? 0, 0.05)
        return RoundedRectangle(cornerRadius: 8)
            .fill(muscle.color.opacity(0.15 + intensity * 0.7))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(muscle.color.opacity(0.4), lineWidth: 1))
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
    }
}

// MARK: - Arka Vücut SVG

struct BodyBackView: View {
    let intensity: [MuscleGroup: Double]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Baş (arka)
                Ellipse()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: w * 0.35, height: h * 0.14)
                    .position(x: w * 0.5, y: h * 0.07)

                // Sırt
                bodyPart(.back, w: w, h: h,
                         rect: CGRect(x: w*0.2, y: h*0.18, width: w*0.6, height: h*0.24))

                // Omuzlar
                bodyPart(.shoulders, w: w, h: h,
                         rect: CGRect(x: w*0.03, y: h*0.17, width: w*0.17, height: h*0.10))
                bodyPart(.shoulders, w: w, h: h,
                         rect: CGRect(x: w*0.80, y: h*0.17, width: w*0.17, height: h*0.10))

                // Kalça
                bodyPart(.glutes, w: w, h: h,
                         rect: CGRect(x: w*0.23, y: h*0.44, width: w*0.54, height: h*0.12))

                // Bacaklar (arka)
                bodyPart(.legs, w: w, h: h,
                         rect: CGRect(x: w*0.23, y: h*0.56, width: w*0.22, height: h*0.38))
                bodyPart(.legs, w: w, h: h,
                         rect: CGRect(x: w*0.55, y: h*0.56, width: w*0.22, height: h*0.38))
            }
        }
    }

    private func bodyPart(_ muscle: MuscleGroup, w: CGFloat, h: CGFloat, rect: CGRect) -> some View {
        let intensity = max(intensity[muscle] ?? 0, 0.05)
        return RoundedRectangle(cornerRadius: 8)
            .fill(muscle.color.opacity(0.15 + intensity * 0.7))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(muscle.color.opacity(0.4), lineWidth: 1))
            .frame(width: rect.width, height: rect.height)
            .position(x: rect.midX, y: rect.midY)
    }
}
