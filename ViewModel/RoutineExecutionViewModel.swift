import Foundation
import Combine

class RoutineExecutionViewModel: ObservableObject {
    let routine: Routine
    let poseEstimator: PoseEstimator
    
    @Published var currentExerciseIndex: Int = 0
    @Published var isResting: Bool = false
    @Published var restTimeRemaining: Int = 30
    @Published var isRoutineFinished: Bool = false
    
    private var restTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    init(routine: Routine, poseEstimator: PoseEstimator) {
        self.routine = routine
        self.poseEstimator = poseEstimator
        
        setupBindings()
        startCurrentExercise()
    }
    
    var currentExercise: (ExerciseType, Int)? {
        guard currentExerciseIndex < routine.exercises.count else { return nil }
        return routine.exercises[currentExerciseIndex]
    }
    
    var nextExercise: (ExerciseType, Int)? {
        guard currentExerciseIndex + 1 < routine.exercises.count else { return nil }
        return routine.exercises[currentExerciseIndex + 1]
    }
    
    private func setupBindings() {
        poseEstimator.$repCount
            .sink { [weak self] currentReps in
                self?.checkRepCompletion(currentReps: currentReps)
            }
            .store(in: &cancellables)
    }
    
    private func checkRepCompletion(currentReps: Int) {
        guard !isResting, let currentEx = currentExercise else { return }
        let targetReps = currentEx.1
        
        if currentReps >= targetReps {
            // Tamamlandı
            completeCurrentExercise()
        }
    }
    
    private func startCurrentExercise() {
        guard let currentEx = currentExercise else {
            // Rutin bitti
            finishRoutine()
            return
        }
        
        poseEstimator.repCount = 0
        poseEstimator.currentExercise = currentEx.0
        isResting = false
    }
    
    private func completeCurrentExercise() {
        if nextExercise != nil {
            startRest()
        } else {
            finishRoutine()
        }
    }
    
    private func startRest() {
        isResting = true
        restTimeRemaining = 30 // 30 saniye dinlenme
        
        SpeechManager.shared.speak("Tebrikler. Şimdi 30 saniye dinlenme zamanı.")
        
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            if self.restTimeRemaining > 0 {
                self.restTimeRemaining -= 1
                
                // Son 3 saniye geri sayım
                if self.restTimeRemaining <= 3 && self.restTimeRemaining > 0 {
                    SpeechManager.shared.speak("\(self.restTimeRemaining)")
                }
                
            } else {
                timer.invalidate()
                self.currentExerciseIndex += 1
                SpeechManager.shared.speak("Sıradaki hareket: \(self.currentExercise?.0.rawValue ?? "")")
                self.startCurrentExercise()
            }
        }
    }
    
    func skipRest() {
        restTimer?.invalidate()
        restTimeRemaining = 0
        currentExerciseIndex += 1
        SpeechManager.shared.speak("Dinlenme geçildi. Sıradaki hareket: \(self.currentExercise?.0.rawValue ?? "")")
        startCurrentExercise()
    }
    
    private func finishRoutine() {
        isRoutineFinished = true
        restTimer?.invalidate()
        SpeechManager.shared.speak("Harika iş çıkardınız. Rutin tamamlandı!")
    }
    
    deinit {
        restTimer?.invalidate()
    }
}
