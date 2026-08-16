import SwiftUI

struct HomeView: View {
    @State private var selectedExercise: ExerciseType? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Koyu Arka Plan
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Text("FitnessAI")
                        .font(.system(size: 45, weight: .heavy, design: .rounded))
                        .foregroundColor(.cyan)
                        .padding(.top, 40)
                    
                    Text("Hangi egzersizi yapmak istersiniz?")
                        .font(.title3)
                        .foregroundColor(.gray)
                    
                    // AI Koç Butonu
                    NavigationLink(destination: AICoachView()) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.title2)
                            Text("AI Koç ile Konuş")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(LinearGradient(colors: [.purple, .indigo], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(20)
                    }
                    .padding(.bottom, 10)
                    
                    Spacer()
                    
                    // Egzersiz Seçim Butonları
                    ForEach(ExerciseType.allCases, id: \.self) { exercise in
                        NavigationLink(destination: ContentView(exercise: exercise)) {
                            HStack {
                                Image(systemName: exercise.iconName)
                                    .font(.system(size: 30))
                                    .frame(width: 50)
                                    .foregroundColor(.white)
                                
                                Text(exercise.rawValue)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(Color.white.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 25)
            }
        }
        .preferredColorScheme(.dark)
    }
}
