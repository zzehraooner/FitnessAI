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
                        Text("Hazır Antrenmanlar")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                            .padding(.horizontal)
                        
                        Text("Yapay Zeka kamerasının sizi baştan sona takip edeceği bir rutin seçin.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        // Kendi Rutinini Yarat Butonu (Premium)
                        Button(action: {
                            viewModel.createCustomRoutineTapped()
                        }) {
                            HStack {
                                Image(systemName: viewModel.storeManager.isPremiumUser ? "plus.circle.fill" : "lock.fill")
                                Text(viewModel.storeManager.isPremiumUser ? "Kendi Rutinini Yarat" : "Özel Rutin Yarat (PRO)")
                            }
                            .font(.headline)
                            .foregroundColor(viewModel.storeManager.isPremiumUser ? .white : .yellow)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.storeManager.isPremiumUser ? Color.cyan.opacity(0.3) : Color.yellow.opacity(0.2))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(viewModel.storeManager.isPremiumUser ? Color.cyan : Color.yellow, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        
                        ForEach(viewModel.routines) { routine in
                            NavigationLink(destination: ContentView(exercise: routine.exercises.first!.0)) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(routine.title)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                        
                                        Text(routine.description)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.leading)
                                        
                                        HStack {
                                            ForEach(routine.exercises, id: \.0.rawValue) { ex in
                                                Text("\(ex.1) x \(ex.0.rawValue)")
                                                    .font(.caption2)
                                                    .padding(5)
                                                    .background(Color.white.opacity(0.2))
                                                    .cornerRadius(5)
                                                    .foregroundColor(.white)
                                            }
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(routine.color)
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(routine.color.opacity(0.5), lineWidth: 2)
                                )
                                .padding(.horizontal)
                            }
                        }
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
                        Text("Squat").tag(ExerciseType.squat)
                        Text("Şınav").tag(ExerciseType.pushup)
                    }
                    
                    Stepper("Tekrar: \(repCount)", value: $repCount, in: 1...100)
                }
                
                Button(action: {
                    let newRoutine = Routine(title: title.isEmpty ? "Özel Rutin" : title,
                                             description: description,
                                             exercises: [(exerciseSelection, repCount)],
                                             color: .purple)
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
