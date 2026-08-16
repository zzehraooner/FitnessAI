import SwiftUI

struct WorkoutRoutineView: View {
    @StateObject private var viewModel: WorkoutRoutineViewModel

    init(storeManager: StoreManager) {
        _viewModel = StateObject(wrappedValue: WorkoutRoutineViewModel(storeManager: storeManager))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Başlık
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hazır Antrenmanlar")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(.white)

                            Text("AI kamerasının sizi baştan sona takip edeceği bir rutin seçin.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal)

                        // Özel Rutin Butonu (Premium)
                        Button(action: { viewModel.createCustomRoutineTapped() }) {
                            HStack {
                                Image(systemName: viewModel.storeManager.isPremiumUser ? "plus.circle.fill" : "lock.fill")
                                Text(viewModel.storeManager.isPremiumUser ? "Kendi Rutinini Yarat" : "Özel Rutin Yarat (PRO)")
                            }
                            .font(.headline)
                            .foregroundColor(viewModel.storeManager.isPremiumUser ? .white : .yellow)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.storeManager.isPremiumUser ? Color.cyan.opacity(0.2) : Color.yellow.opacity(0.15))
                            .cornerRadius(15)
                            .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(viewModel.storeManager.isPremiumUser ? Color.cyan : Color.yellow, lineWidth: 1))
                        }
                        .padding(.horizontal)

                        // Rutin Kartları
                        ForEach(viewModel.routines) { routine in
                            NavigationLink(destination: RoutineExecutionView(
                                viewModel: RoutineExecutionViewModel(routine: routine, poseEstimator: PoseEstimator())
                            )) {
                                RoutineCard(routine: routine)
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showingAddRoutine) {
                AddRoutineView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showingPaywall) {
                PaywallView(storeManager: viewModel.storeManager)
            }
        }
    }
}

// MARK: - Rutin Kartı

struct RoutineCard: View {
    let routine: Routine

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Üst: İkon + Zorluk + Süre
            HStack {
                Image(systemName: routine.imageSystemName)
                    .font(.title2)
                    .foregroundColor(routine.color)
                    .frame(width: 44, height: 44)
                    .background(routine.color.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Spacer()

                // Zorluk etiketi
                HStack(spacing: 4) {
                    Image(systemName: routine.difficulty.iconName)
                        .font(.caption)
                    Text(routine.difficulty.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundColor(routine.difficulty.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(routine.difficulty.color.opacity(0.15))
                .cornerRadius(8)

                // Tahmini süre
                HStack(spacing: 3) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                    Text("\(routine.estimatedMinutes) dk")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.gray)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.08))
                .cornerRadius(8)
            }

            // Başlık + Açıklama
            VStack(alignment: .leading, spacing: 4) {
                Text(routine.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(routine.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }

            // Egzersiz chip'leri
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(routine.exercises, id: \.0.rawValue) { ex in
                        HStack(spacing: 4) {
                            Image(systemName: ex.0.iconName)
                                .font(.caption2)
                            Text("\(ex.1)x \(ex.0.rawValue)")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }

            // Başlat butonu
            HStack {
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                    Text("Başlat")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(routine.color)
                .cornerRadius(20)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.07))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(routine.color.opacity(0.4), lineWidth: 1.5))
    }
}

// MARK: - Özel Rutin Ekle

struct AddRoutineView: View {
    @ObservedObject var viewModel: WorkoutRoutineViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var description = ""
    @State private var exerciseSelection: ExerciseType = .squat
    @State private var repCount: Int = 10

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Rutin Bilgileri")) {
                    TextField("Rutin Adı", text: $title)
                    TextField("Açıklama", text: $description)
                }

                Section(header: Text("Hareket Ekle")) {
                    Picker("Hareket", selection: $exerciseSelection) {
                        ForEach(ExerciseType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.iconName)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    Stepper("Tekrar: \(repCount)", value: $repCount, in: 1...100)
                }

                Button(action: {
                    let newRoutine = Routine(
                        title: title.isEmpty ? "Özel Rutin" : title,
                        description: description,
                        exercises: [(exerciseSelection, repCount)],
                        color: .purple,
                        difficulty: .intermediate,
                        estimatedMinutes: max(5, repCount / 3)
                    )
                    viewModel.addRoutine(newRoutine)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Kaydet")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle("Yeni Rutin")
            .navigationBarItems(trailing: Button("İptal") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
