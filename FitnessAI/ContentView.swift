import SwiftUI

struct ContentView: View {
    let exercise: ExerciseType
    @StateObject var poseEstimator = PoseEstimator()
    @StateObject var healthManager = HealthManager()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            CameraView(poseEstimator: poseEstimator)
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                ZStack {
                    ForEach(Array(poseEstimator.bodyPoints.keys), id: \.self) { key in
                        if let point = poseEstimator.bodyPoints[key] {
                            Circle()
                                .fill(Color.cyan)
                                .frame(width: 12, height: 12)
                                .shadow(color: .cyan, radius: 4, x: 0, y: 0)
                                .position(x: point.x * geometry.size.width, y: point.y * geometry.size.height)
                        }
                    }
                }
            }
            
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.trailing, 10)
                    
                    VStack(alignment: .leading) {
                        Text(exercise.rawValue.uppercased())
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("\(poseEstimator.repCount) Tekrar")
                            .font(.system(size: 35, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Nabız Göstergesi
                    VStack(alignment: .trailing) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        
                        Text(String(format: "%.0f BPM", healthManager.heartRate))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.top, 50)
                .padding(.horizontal, 20)
                
                Spacer()
                
                VStack(spacing: 15) {
                    Text(poseEstimator.feedbackMessage)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .cornerRadius(15)
                    
                    HStack {
                        Text("Form:")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(String(format: "%.0f%%", poseEstimator.formPercentage))
                            .font(.system(size: 30, weight: .heavy, design: .rounded))
                            .foregroundColor(colorForPercentage(poseEstimator.formPercentage))
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 20)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            poseEstimator.currentExercise = exercise
        }
    }
    
    func colorForPercentage(_ percentage: Double) -> Color {
        if percentage >= 90 { return .green }
        else if percentage >= 70 { return .yellow }
        else { return .red }
    }
}
