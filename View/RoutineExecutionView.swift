import SwiftUI

struct RoutineExecutionView: View {
    @StateObject var viewModel: RoutineExecutionViewModel
    @StateObject var healthManager = HealthManager()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            if !viewModel.isRoutineFinished {
                CameraView(poseEstimator: viewModel.poseEstimator)
                    .edgesIgnoringSafeArea(.all)
                
                // Noktalar
                GeometryReader { geometry in
                    ZStack {
                        ForEach(Array(viewModel.poseEstimator.bodyPoints.keys), id: \.self) { key in
                            if let point = viewModel.poseEstimator.bodyPoints[key] {
                                Circle()
                                    .fill(Color.cyan)
                                    .frame(width: 12, height: 12)
                                    .shadow(color: .cyan, radius: 4, x: 0, y: 0)
                                    .position(x: point.x * geometry.size.width, y: point.y * geometry.size.height)
                            }
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
                        if viewModel.isRoutineFinished {
                            Text("TAMAMLANDI")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.7))
                        } else if let ex = viewModel.currentExercise {
                            Text(ex.0.rawValue.uppercased())
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text("\(viewModel.poseEstimator.repCount) / \(ex.1)")
                                .font(.system(size: 35, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                        }
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
                
                if viewModel.isRoutineFinished {
                    VStack(spacing: 20) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.yellow)
                        
                        Text("Rutini Tamamladınız!")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                        
                        Button("Bitir") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(15)
                    }
                    .padding(40)
                    .background(Color.black.opacity(0.8))
                    .cornerRadius(25)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                } else if viewModel.isResting {
                    VStack(spacing: 15) {
                        Text("DİNLENME")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.cyan)
                        
                        Text("\(viewModel.restTimeRemaining)")
                            .font(.system(size: 70, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        if let nextEx = viewModel.nextExercise {
                            Text("Sıradaki: \(nextEx.0.rawValue) (x\(nextEx.1))")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        
                        Button("Geç") {
                            viewModel.skipRest()
                        }
                        .padding(.top, 10)
                        .foregroundColor(.white)
                    }
                    .padding(40)
                    .background(.ultraThinMaterial)
                    .cornerRadius(25)
                    
                    Spacer()
                } else {
                    VStack(spacing: 15) {
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
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text(String(format: "%.0f%%", viewModel.poseEstimator.formPercentage))
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .foregroundColor(colorForPercentage(viewModel.poseEstimator.formPercentage))
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
        }
        .navigationBarHidden(true)
    }
    
    func colorForPercentage(_ percentage: Double) -> Color {
        if percentage >= 90 { return .green }
        else if percentage >= 70 { return .yellow }
        else { return .red }
    }
}
