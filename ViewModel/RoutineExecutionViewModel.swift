import Foundation
import Combine

class RoutineExecutionViewModel: ObservableObject {
    let routine: Routine
    let poseEstimator: PoseEstimator

    @Published var currentExerciseIndex: Int = 0
    @Published var isResting: Bool = false
    @Published var restTimeRemaining: Int = 30
    @Published var isRoutineFinished: Bool = false

    // Süre ve form takibi
    @Published var totalElapsedSeconds: Int = 0
    @Published var totalCompletedReps: Int = 0
    @Published var averageFormPercentage: Double = 0

    private var restTimer: Timer?
    private var elapsedTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    // Form birikimi
    private var formSampleCount: Int = 0
    private var formSampleSum: Double = 0

    init(routine: Routine, poseEstimator: PoseEstimator) {
        self.routine = routine
        self.poseEstimator = poseEstimator

        setupBindings()
        startElapsedTimer()
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

    /// İlerleme: 0.0 – 1.0
    var progress: Double {
        let total = routine.exercises.count
        guard total > 0 else { return 0 }
        return Double(currentExerciseIndex) / Double(total)
    }

    var formattedElapsedTime: String {
        let minutes = totalElapsedSeconds / 60
        let seconds = totalElapsedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Setup

    private func setupBindings() {
        // Tekrar tamamlanma takibi
        poseEstimator.$repCount
            .sink { [weak self] currentReps in
                self?.checkRepCompletion(currentReps: currentReps)
            }
            .store(in: &cancellables)

        // Form yüzdesi birikimi
        poseEstimator.$formPercentage
            .sink { [weak self] pct in
                guard let self = self, pct > 0 else { return }
                self.formSampleSum += pct
                self.formSampleCount += 1
                self.averageFormPercentage = self.formSampleSum / Double(self.formSampleCount)
            }
            .store(in: &cancellables)
    }

    private func startElapsedTimer() {
        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.totalElapsedSeconds += 1
        }
    }

    // MARK: - Flow

    private func checkRepCompletion(currentReps: Int) {
        guard !isResting, let currentEx = currentExercise else { return }
        let targetReps = currentEx.1

        if currentReps >= targetReps {
            totalCompletedReps += currentReps
            completeCurrentExercise()
        }
    }

    private func startCurrentExercise() {
        guard let currentEx = currentExercise else {
            finishRoutine()
            return
        }

        poseEstimator.repCount = 0
        poseEstimator.currentExercise = currentEx.0
        isResting = false

        // Watch'a sıradaki egzersiz bildir
        WatchConnectivityManager.shared.sendFormDataToWatch(
            formPercentage: 0,
            isResting: false,
            nextExercise: currentEx.0.rawValue
        )
    }

    private func completeCurrentExercise() {
        if nextExercise != nil {
            startRest()
        } else {
            // Son egzersiz için de tekrar sayısını ekle
            totalCompletedReps += poseEstimator.repCount
            finishRoutine()
        }
    }

    private func startRest() {
        isResting = true
        restTimeRemaining = 30

        SpeechManager.shared.speak("Tebrikler. Şimdi 30 saniye dinlenme zamanı.")

        // Watch'a dinlenme modu bildir
        WatchConnectivityManager.shared.sendFormDataToWatch(
            formPercentage: averageFormPercentage,
            isResting: true,
            nextExercise: nextExercise?.0.rawValue
        )

        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { timer.invalidate(); return }

            if self.restTimeRemaining > 0 {
                self.restTimeRemaining -= 1

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
        elapsedTimer?.invalidate()

        SpeechManager.shared.speak("Harika iş çıkardınız. Rutin tamamlandı!")

        // Seans kaydet
        let session = WorkoutSession(
            exerciseName: routine.title,
            totalReps: totalCompletedReps,
            durationSeconds: totalElapsedSeconds,
            averageFormPercentage: averageFormPercentage,
            date: Date(),
            routineTitle: routine.title
        )
        SessionStore.shared.save(session)

        // Watch'a tamamlandı bildir
        WatchConnectivityManager.shared.sendRoutineFinishedToWatch(
            totalReps: totalCompletedReps,
            totalMinutes: totalElapsedSeconds / 60
        )
    }

    deinit {
        restTimer?.invalidate()
        elapsedTimer?.invalidate()
    }
}


