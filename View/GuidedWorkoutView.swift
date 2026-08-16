import SwiftUI

struct GuidedWorkoutView: View {
    let exerciseType: ExerciseType
    @StateObject private var manager = GuidedWorkoutManager.shared
    @State private var currentStep = 0
    @State private var showCountdown = true
    @State private var countdown = 3
    @State private var stepProgress: Double = 0
    @State private var animatePulse = false
    @Environment(\.presentationMode) var presentationMode

    private var steps: [ExerciseStep] { GuidedWorkoutManager.steps(for: exerciseType) }
    private var step: ExerciseStep { steps[min(currentStep, steps.count - 1)] }

    var body: some View {
        ZStack {
            // Dinamik arka plan
            LinearGradient(
                colors: [Color.black, step.accentColor.opacity(0.15)],
                startPoint: .top, endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            .animation(.easeInOut(duration: 0.6), value: currentStep)

            if showCountdown {
                countdownView
            } else {
                mainContent
            }
        }
        .navigationBarHidden(true)
        .onAppear { startCountdown() }
    }

    // MARK: - Geri Sayım

    private var countdownView: some View {
        VStack(spacing: 20) {
            Text("Hazır Mısın?")
                .font(.title2).fontWeight(.bold).foregroundColor(.white)

            Text("\(countdown)")
                .font(.system(size: 120, weight: .black, design: .rounded))
                .foregroundColor(step.accentColor)
                .scaleEffect(animatePulse ? 1.15 : 1.0)
                .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: animatePulse)

            Text(exerciseType.rawValue)
                .font(.headline).foregroundColor(.gray)
        }
    }

    // MARK: - Ana İçerik

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Üst bar
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Text(exerciseType.rawValue)
                    .font(.headline).fontWeight(.bold).foregroundColor(.white)
                Spacer()
                Text("\(currentStep + 1)/\(steps.count)")
                    .font(.caption).foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 20)

            // Adım ilerleme
            stepProgressBar

            Spacer()

            // Animasyonlu ikon
            exerciseIcon

            Spacer()

            // Faz bilgileri
            phaseCard

            // Önceki / Sonraki navigasyon
            navigationButtons
                .padding(.bottom, 50)
        }
    }

    // MARK: - Adım İlerleme

    private var stepProgressBar: some View {
        HStack(spacing: 6) {
            ForEach(steps.indices, id: \.self) { i in
                Capsule()
                    .fill(i <= currentStep ? step.accentColor : Color.white.opacity(0.2))
                    .frame(height: 4)
                    .animation(.spring(), value: currentStep)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Animasyonlu İkon

    private var exerciseIcon: some View {
        ZStack {
            // Glow halka
            Circle()
                .fill(step.accentColor.opacity(0.15))
                .frame(width: 200, height: 200)
                .scaleEffect(animatePulse ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animatePulse)

            Circle()
                .strokeBorder(step.accentColor.opacity(0.4), lineWidth: 2)
                .frame(width: 200, height: 200)

            Image(systemName: step.systemIcon)
                .font(.system(size: 80))
                .foregroundStyle(LinearGradient(
                    colors: [step.accentColor, step.accentColor.opacity(0.6)],
                    startPoint: .top, endPoint: .bottom
                ))
                .symbolEffect(.bounce, value: currentStep)
        }
        .onAppear { animatePulse = true }
    }

    // MARK: - Faz Kartı

    private var phaseCard: some View {
        VStack(spacing: 16) {
            // Faz etiketi
            Text(step.phase.uppercased())
                .font(.caption).fontWeight(.heavy)
                .foregroundColor(step.accentColor)
                .kerning(2)
                .padding(.horizontal, 14).padding(.vertical, 5)
                .background(step.accentColor.opacity(0.15))
                .cornerRadius(8)

            // Açıklama
            Text(step.description)
                .font(.title3).fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .lineSpacing(4)
                .padding(.horizontal, 10)

            // Süre göstergesi
            HStack(spacing: 6) {
                Image(systemName: "clock").font(.caption).foregroundColor(.gray)
                Text("≈ \(Int(step.durationSeconds)) saniye")
                    .font(.caption).foregroundColor(.gray)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(24)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .id(currentStep) // Her adım değişiminde yeniden render
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal:   .move(edge: .leading).combined(with: .opacity)
        ))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
    }

    // MARK: - Navigasyon Butonları

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Önceki
            Button(action: {
                if currentStep > 0 { withAnimation { currentStep -= 1 } }
            }) {
                HStack { Image(systemName: "chevron.left"); Text("Önceki") }
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundColor(currentStep > 0 ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(currentStep > 0 ? 0.1 : 0.04))
                    .cornerRadius(14)
            }
            .disabled(currentStep == 0)

            // Sonraki / Tamamla
            Button(action: {
                if currentStep < steps.count - 1 {
                    withAnimation { currentStep += 1 }
                } else {
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                HStack {
                    Text(currentStep < steps.count - 1 ? "Sonraki" : "Antrenmanı Başlat")
                    Image(systemName: currentStep < steps.count - 1 ? "chevron.right" : "play.fill")
                }
                .font(.subheadline).fontWeight(.bold)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(step.accentColor)
                .cornerRadius(14)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Geri Sayım

    private func startCountdown() {
        animatePulse = true
        var c = 3
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            c -= 1
            countdown = c
            if c <= 0 {
                timer.invalidate()
                withAnimation { showCountdown = false }
            }
        }
    }
}
