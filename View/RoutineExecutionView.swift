import SwiftUI

struct RoutineExecutionView: View {
    @StateObject var viewModel: RoutineExecutionViewModel
    @StateObject var healthManager = HealthManager()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // Kamera Arka Plan
            if !viewModel.isRoutineFinished {
                CameraView(poseEstimator: viewModel.poseEstimator)
                    .edgesIgnoringSafeArea(.all)

                // Skeleton Noktaları
                GeometryReader { geometry in
                    ZStack {
                        ForEach(Array(viewModel.poseEstimator.bodyPoints.keys), id: \.self) { key in
                            if let point = viewModel.poseEstimator.bodyPoints[key] {
                                Circle()
                                    .fill(Color.cyan)
                                    .frame(width: 12, height: 12)
                                    .shadow(color: .cyan, radius: 4)
                                    .position(x: point.x * geometry.size.width,
                                              y: point.y * geometry.size.height)
                            }
                        }
                    }
                }
            }

            VStack(spacing: 0) {
                // MARK: — Üst Bar
                VStack(spacing: 10) {
                    HStack(alignment: .center) {
                        // Kapat butonu
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.8))
                        }

                        Spacer()

                        // Egzersiz adı + Tekrar
                        VStack(spacing: 2) {
                            if viewModel.isRoutineFinished {
                                Text("TAMAMLANDI ✅")
                                    .font(.subheadline).fontWeight(.bold).foregroundColor(.green)
                            } else if let ex = viewModel.currentExercise {
                                Text(ex.0.rawValue.uppercased())
                                    .font(.caption).fontWeight(.bold).foregroundColor(.white.opacity(0.7))
                                Text("\(viewModel.poseEstimator.repCount) / \(ex.1)")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                            }
                        }

                        Spacer()

                        // Nabız + Süre
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack(spacing: 3) {
                                Image(systemName: "heart.fill").foregroundColor(.red).font(.caption)
                                Text(String(format: "%.0f BPM", healthManager.heartRate))
                                    .font(.caption).fontWeight(.bold).foregroundColor(.white)
                            }
                            HStack(spacing: 3) {
                                Image(systemName: "timer").foregroundColor(.cyan).font(.caption)
                                Text(viewModel.formattedElapsedTime)
                                    .font(.caption).fontWeight(.bold).foregroundColor(.cyan)
                            }
                        }
                    }

                    // İlerleme çubuğu: Egzersiz X / Toplam
                    if !viewModel.isRoutineFinished {
                        VStack(spacing: 4) {
                            HStack {
                                Text("Egzersiz \(viewModel.currentExerciseIndex + 1) / \(viewModel.routine.exercises.count)")
                                    .font(.caption2).foregroundColor(.gray)
                                Spacer()
                                Text("\(Int(viewModel.progress * 100))%")
                                    .font(.caption2).foregroundColor(.gray)
                            }
                            ProgressView(value: viewModel.progress)
                                .tint(.cyan)
                                .scaleEffect(x: 1, y: 1.5)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.top, 50)
                .padding(.horizontal, 16)

                Spacer()

                // MARK: — Alt Panel
                if viewModel.isRoutineFinished {
                    routineCompletionPanel
                } else if viewModel.isResting {
                    restPanel
                } else {
                    formFeedbackPanel
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Tamamlanma Ekranı

    private var routineCompletionPanel: some View {
        VStack(spacing: 20) {
            // Başlık
            VStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom))

                Text("Rutin Tamamlandı! 🎉")
                    .font(.title2).fontWeight(.heavy).foregroundColor(.white)
            }

            // Özet Kartlar
            HStack(spacing: 12) {
                SummaryStatCard(icon: "repeat.circle.fill", value: "\(viewModel.totalCompletedReps)", label: "Tekrar", color: .cyan)
                SummaryStatCard(icon: "clock.fill", value: viewModel.formattedElapsedTime, label: "Süre", color: .orange)
                SummaryStatCard(
                    icon: "figure.arms.open",
                    value: String(format: "%.0f%%", viewModel.averageFormPercentage),
                    label: "Ort. Form",
                    color: formColor(viewModel.averageFormPercentage)
                )
            }

            // Butonlar
            VStack(spacing: 10) {
                NavigationLink(destination: ShareSummaryView()) {
                    Label("Sonuçları Paylaş", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.cyan.opacity(0.3))
                        .cornerRadius(15)
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.cyan, lineWidth: 1))
                }

                Button("Bitir") { presentationMode.wrappedValue.dismiss() }
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(15)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }

    // MARK: - Dinlenme Ekranı

    private var restPanel: some View {
        VStack(spacing: 14) {
            Text("DİNLENME")
                .font(.title3).fontWeight(.bold).foregroundColor(.cyan)

            Text("\(viewModel.restTimeRemaining)")
                .font(.system(size: 70, weight: .black, design: .rounded))
                .foregroundColor(.white)

            if let nextEx = viewModel.nextExercise {
                HStack(spacing: 8) {
                    Image(systemName: nextEx.0.iconName)
                        .font(.title3).foregroundColor(.gray)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sıradaki")
                            .font(.caption2).foregroundColor(.gray)
                        Text("\(nextEx.0.rawValue) — \(nextEx.1) tekrar")
                            .font(.subheadline).fontWeight(.semibold).foregroundColor(.white)
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
            }

            Button("Geç →") { viewModel.skipRest() }
                .foregroundColor(.cyan)
                .font(.subheadline.bold())
        }
        .padding(28)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }

    // MARK: - Form Geri Bildirim Paneli

    private var formFeedbackPanel: some View {
        VStack(spacing: 12) {
            Text(viewModel.poseEstimator.feedbackMessage)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(15)

            HStack {
                Text("Form:")
                    .font(.title2).fontWeight(.bold).foregroundColor(.white)
                Spacer()
                Text(String(format: "%.0f%%", viewModel.poseEstimator.formPercentage))
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(colorForPercentage(viewModel.poseEstimator.formPercentage))
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 18)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }

    // MARK: - Helpers

    func colorForPercentage(_ p: Double) -> Color {
        if p >= 90 { return .green } else if p >= 70 { return .yellow } else { return .red }
    }

    func formColor(_ p: Double) -> Color {
        if p >= 90 { return .green } else if p >= 70 { return .yellow } else { return .orange }
    }
}

// MARK: — Özet İstatistik Kartı

struct SummaryStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.12))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.3), lineWidth: 1))
    }
}



