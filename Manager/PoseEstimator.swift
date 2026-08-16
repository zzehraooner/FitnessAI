import Foundation
import Vision
import Combine
import AVFoundation
import UIKit

class PoseEstimator: ObservableObject {
    @Published var formPercentage: Double = 0
    @Published var feedbackMessage: String = "Kameranın karşısına geçin"
    @Published var bodyPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
    @Published var repCount: Int = 0

    var currentExercise: ExerciseType = .squat

    let sequenceHandler = VNSequenceRequestHandler()

    private var isDown = false
    private var lastSpokenMessage = ""
    private var lastStableTime: Date?

    func processFrame(_ sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)
        do {
            try sequenceHandler.perform([request], on: pixelBuffer, orientation: .up)
        } catch {
            print("Vision error: \(error.localizedDescription)")
        }
    }

    func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation],
              let observation = observations.first else { return }

        do {
            let recognizedPoints = try observation.recognizedPoints(.all)

            var points: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
            for (key, point) in recognizedPoints where point.confidence > 0.3 {
                points[key] = CGPoint(x: point.location.x, y: 1 - point.location.y)
            }

            DispatchQueue.main.async {
                self.bodyPoints = points
                self.analyzeForm()
            }
        } catch {
            print("Error retrieving points")
        }
    }

    // MARK: - Yardımcı: Çift Taraflı Analiz

    /// İki tarafın sonucunu birleştir: her ikisi de geçerliyse ortalama al,
    /// sadece biri geçerliyse onu kullan.
    private func combinedResult(
        left: (percentage: Double, message: String, state: ExerciseState),
        right: (percentage: Double, message: String, state: ExerciseState)
    ) -> (percentage: Double, message: String, state: ExerciseState) {
        let leftValid  = left.state != .unknown || left.percentage > 0
        let rightValid = right.state != .unknown || right.percentage > 0

        switch (leftValid, rightValid) {
        case (true, true):
            // Her iki taraf da geçerli → ortalama form, daha kötü durum mesajı
            let avgPct = (left.percentage + right.percentage) / 2.0
            // Daha düşük form yüzdesinin mesajını göster (daha kritik)
            let msg = left.percentage <= right.percentage ? left.message : right.message
            // State: ikisi de down ise down, ikisi de up ise up, aksi unknown
            let state: ExerciseState = left.state == right.state ? left.state : .unknown
            return (avgPct, msg, state)
        case (true, false):
            return left
        case (false, true):
            return right
        default:
            return left // İkisi de geçersiz — sol tarafın hata mesajını dön
        }
    }

    // MARK: - Form Analizi

    private func analyzeForm() {
        let result: (percentage: Double, message: String, state: ExerciseState)

        switch currentExercise {

        case .squat:
            let leftResult  = ExerciseAnalyzer.analyzeSquat(hip: bodyPoints[.leftHip],  knee: bodyPoints[.leftKnee],  ankle: bodyPoints[.leftAnkle])
            let rightResult = ExerciseAnalyzer.analyzeSquat(hip: bodyPoints[.rightHip], knee: bodyPoints[.rightKnee], ankle: bodyPoints[.rightAnkle])
            result = combinedResult(left: leftResult, right: rightResult)

        case .pushup:
            let leftResult  = ExerciseAnalyzer.analyzePushup(shoulder: bodyPoints[.leftShoulder],  elbow: bodyPoints[.leftElbow],  wrist: bodyPoints[.leftWrist])
            let rightResult = ExerciseAnalyzer.analyzePushup(shoulder: bodyPoints[.rightShoulder], elbow: bodyPoints[.rightElbow], wrist: bodyPoints[.rightWrist])
            result = combinedResult(left: leftResult, right: rightResult)

        case .lunge:
            let leftResult  = ExerciseAnalyzer.analyzeLunge(hip: bodyPoints[.leftHip],  knee: bodyPoints[.leftKnee],  ankle: bodyPoints[.leftAnkle])
            let rightResult = ExerciseAnalyzer.analyzeLunge(hip: bodyPoints[.rightHip], knee: bodyPoints[.rightKnee], ankle: bodyPoints[.rightAnkle])
            result = combinedResult(left: leftResult, right: rightResult)

        case .jumpingJacks:
            let leftResult  = ExerciseAnalyzer.analyzeJumpingJacks(hip: bodyPoints[.leftHip],  shoulder: bodyPoints[.leftShoulder],  wrist: bodyPoints[.leftWrist])
            let rightResult = ExerciseAnalyzer.analyzeJumpingJacks(hip: bodyPoints[.rightHip], shoulder: bodyPoints[.rightShoulder], wrist: bodyPoints[.rightWrist])
            result = combinedResult(left: leftResult, right: rightResult)

        case .situp:
            let leftResult  = ExerciseAnalyzer.analyzeSitup(shoulder: bodyPoints[.leftShoulder],  hip: bodyPoints[.leftHip],  knee: bodyPoints[.leftKnee])
            let rightResult = ExerciseAnalyzer.analyzeSitup(shoulder: bodyPoints[.rightShoulder], hip: bodyPoints[.rightHip], knee: bodyPoints[.rightKnee])
            result = combinedResult(left: leftResult, right: rightResult)

        case .bicepCurl:
            let leftResult  = ExerciseAnalyzer.analyzeBicepCurl(shoulder: bodyPoints[.leftShoulder],  elbow: bodyPoints[.leftElbow],  wrist: bodyPoints[.leftWrist])
            let rightResult = ExerciseAnalyzer.analyzeBicepCurl(shoulder: bodyPoints[.rightShoulder], elbow: bodyPoints[.rightElbow], wrist: bodyPoints[.rightWrist])
            result = combinedResult(left: leftResult, right: rightResult)

        case .shoulderPress:
            let leftResult  = ExerciseAnalyzer.analyzeShoulderPress(shoulder: bodyPoints[.leftShoulder],  elbow: bodyPoints[.leftElbow],  wrist: bodyPoints[.leftWrist])
            let rightResult = ExerciseAnalyzer.analyzeShoulderPress(shoulder: bodyPoints[.rightShoulder], elbow: bodyPoints[.rightElbow], wrist: bodyPoints[.rightWrist])
            result = combinedResult(left: leftResult, right: rightResult)

        case .deadlift:
            let leftResult  = ExerciseAnalyzer.analyzeDeadlift(shoulder: bodyPoints[.leftShoulder],  hip: bodyPoints[.leftHip],  knee: bodyPoints[.leftKnee])
            let rightResult = ExerciseAnalyzer.analyzeDeadlift(shoulder: bodyPoints[.rightShoulder], hip: bodyPoints[.rightHip], knee: bodyPoints[.rightKnee])
            result = combinedResult(left: leftResult, right: rightResult)

        case .highKnees:
            let leftResult  = ExerciseAnalyzer.analyzeHighKnees(shoulder: bodyPoints[.leftShoulder],  hip: bodyPoints[.leftHip],  knee: bodyPoints[.leftKnee])
            let rightResult = ExerciseAnalyzer.analyzeHighKnees(shoulder: bodyPoints[.rightShoulder], hip: bodyPoints[.rightHip], knee: bodyPoints[.rightKnee])
            result = combinedResult(left: leftResult, right: rightResult)

        case .lateralRaises:
            let leftResult  = ExerciseAnalyzer.analyzeLateralRaises(hip: bodyPoints[.leftHip],  shoulder: bodyPoints[.leftShoulder],  wrist: bodyPoints[.leftWrist])
            let rightResult = ExerciseAnalyzer.analyzeLateralRaises(hip: bodyPoints[.rightHip], shoulder: bodyPoints[.rightShoulder], wrist: bodyPoints[.rightWrist])
            result = combinedResult(left: leftResult, right: rightResult)

        case .gluteBridge:
            let leftResult  = ExerciseAnalyzer.analyzeGluteBridge(shoulder: bodyPoints[.leftShoulder],  hip: bodyPoints[.leftHip],  knee: bodyPoints[.leftKnee])
            let rightResult = ExerciseAnalyzer.analyzeGluteBridge(shoulder: bodyPoints[.rightShoulder], hip: bodyPoints[.rightHip], knee: bodyPoints[.rightKnee])
            result = combinedResult(left: leftResult, right: rightResult)

        case .calfRaises:
            let leftResult  = ExerciseAnalyzer.analyzeCalfRaises(hip: bodyPoints[.leftHip],  knee: bodyPoints[.leftKnee],  ankle: bodyPoints[.leftAnkle])
            let rightResult = ExerciseAnalyzer.analyzeCalfRaises(hip: bodyPoints[.rightHip], knee: bodyPoints[.rightKnee], ankle: bodyPoints[.rightAnkle])
            result = combinedResult(left: leftResult, right: rightResult)

        case .tricepDips:
            let leftResult  = ExerciseAnalyzer.analyzeTricepDips(shoulder: bodyPoints[.leftShoulder],  elbow: bodyPoints[.leftElbow],  wrist: bodyPoints[.leftWrist])
            let rightResult = ExerciseAnalyzer.analyzeTricepDips(shoulder: bodyPoints[.rightShoulder], elbow: bodyPoints[.rightElbow], wrist: bodyPoints[.rightWrist])
            result = combinedResult(left: leftResult, right: rightResult)

        case .legRaises:
            let leftResult  = ExerciseAnalyzer.analyzeLegRaises(shoulder: bodyPoints[.leftShoulder],  hip: bodyPoints[.leftHip],  knee: bodyPoints[.leftKnee])
            let rightResult = ExerciseAnalyzer.analyzeLegRaises(shoulder: bodyPoints[.rightShoulder], hip: bodyPoints[.rightHip], knee: bodyPoints[.rightKnee])
            result = combinedResult(left: leftResult, right: rightResult)

        case .frontRaises:
            let leftResult  = ExerciseAnalyzer.analyzeFrontRaises(hip: bodyPoints[.leftHip],  shoulder: bodyPoints[.leftShoulder],  wrist: bodyPoints[.leftWrist])
            let rightResult = ExerciseAnalyzer.analyzeFrontRaises(hip: bodyPoints[.rightHip], shoulder: bodyPoints[.rightShoulder], wrist: bodyPoints[.rightWrist])
            result = combinedResult(left: leftResult, right: rightResult)

        case .mountainClimbers:
            let leftResult  = ExerciseAnalyzer.analyzeMountainClimbers(shoulder: bodyPoints[.leftShoulder],  hip: bodyPoints[.leftHip],  knee: bodyPoints[.leftKnee])
            let rightResult = ExerciseAnalyzer.analyzeMountainClimbers(shoulder: bodyPoints[.rightShoulder], hip: bodyPoints[.rightHip], knee: bodyPoints[.rightKnee])
            result = combinedResult(left: leftResult, right: rightResult)

        case .donkeyKicks:
            let leftResult  = ExerciseAnalyzer.analyzeDonkeyKicks(shoulder: bodyPoints[.leftShoulder],  hip: bodyPoints[.leftHip],  knee: bodyPoints[.leftKnee])
            let rightResult = ExerciseAnalyzer.analyzeDonkeyKicks(shoulder: bodyPoints[.rightShoulder], hip: bodyPoints[.rightHip], knee: bodyPoints[.rightKnee])
            result = combinedResult(left: leftResult, right: rightResult)

        case .crunch:
            let leftResult  = ExerciseAnalyzer.analyzeCrunch(shoulder: bodyPoints[.leftShoulder],  hip: bodyPoints[.leftHip],  knee: bodyPoints[.leftKnee])
            let rightResult = ExerciseAnalyzer.analyzeCrunch(shoulder: bodyPoints[.rightShoulder], hip: bodyPoints[.rightHip], knee: bodyPoints[.rightKnee])
            result = combinedResult(left: leftResult, right: rightResult)

        case .bentOverRow:
            let leftResult  = ExerciseAnalyzer.analyzeBentOverRow(shoulder: bodyPoints[.leftShoulder],  elbow: bodyPoints[.leftElbow],  wrist: bodyPoints[.leftWrist])
            let rightResult = ExerciseAnalyzer.analyzeBentOverRow(shoulder: bodyPoints[.rightShoulder], elbow: bodyPoints[.rightElbow], wrist: bodyPoints[.rightWrist])
            result = combinedResult(left: leftResult, right: rightResult)

        case .sumoSquat:
            let leftResult  = ExerciseAnalyzer.analyzeSumoSquat(hip: bodyPoints[.leftHip],  knee: bodyPoints[.leftKnee],  ankle: bodyPoints[.leftAnkle])
            let rightResult = ExerciseAnalyzer.analyzeSumoSquat(hip: bodyPoints[.rightHip], knee: bodyPoints[.rightKnee], ankle: bodyPoints[.rightAnkle])
            result = combinedResult(left: leftResult, right: rightResult)

        case .goodMornings:
            let leftResult  = ExerciseAnalyzer.analyzeGoodMornings(shoulder: bodyPoints[.leftShoulder],  hip: bodyPoints[.leftHip],  knee: bodyPoints[.leftKnee])
            let rightResult = ExerciseAnalyzer.analyzeGoodMornings(shoulder: bodyPoints[.rightShoulder], hip: bodyPoints[.rightHip], knee: bodyPoints[.rightKnee])
            result = combinedResult(left: leftResult, right: rightResult)

        case .treePose:
            // Yoga: dengede duran ayak (sol) analiz edilir
            let leftResult  = ExerciseAnalyzer.analyzeTreePose(hip: bodyPoints[.leftHip],  knee: bodyPoints[.leftKnee],  ankle: bodyPoints[.leftAnkle])
            let rightResult = ExerciseAnalyzer.analyzeTreePose(hip: bodyPoints[.rightHip], knee: bodyPoints[.rightKnee], ankle: bodyPoints[.rightAnkle])
            result = combinedResult(left: leftResult, right: rightResult)

        case .warriorPose:
            let leftResult  = ExerciseAnalyzer.analyzeWarriorPose(hip: bodyPoints[.leftHip],  shoulder: bodyPoints[.leftShoulder],  wrist: bodyPoints[.leftWrist])
            let rightResult = ExerciseAnalyzer.analyzeWarriorPose(hip: bodyPoints[.rightHip], shoulder: bodyPoints[.rightShoulder], wrist: bodyPoints[.rightWrist])
            result = combinedResult(left: leftResult, right: rightResult)
        }

        self.formPercentage = result.percentage
        self.feedbackMessage = result.message

        // Watch'a form verisi gönder
        WatchConnectivityManager.shared.sendFormDataToWatch(
            formPercentage: result.percentage,
            isResting: false
        )

        // Tekrar veya Süre sayacı mantığı
        if currentExercise.isYoga {
            if result.state == .up {
                if let lastStable = lastStableTime {
                    let elapsed = Date().timeIntervalSince(lastStable)
                    if elapsed >= 1.0 {
                        repCount += 1
                        GamificationManager.shared.addRep()
                        WatchConnectivityManager.shared.sendExerciseDataToWatch(exerciseName: currentExercise.rawValue, repCount: repCount)
                        lastStableTime = Date()
                        if repCount % 5 == 0 {
                            SpeechManager.shared.speak("\(repCount) saniye", force: true)
                        }
                    }
                } else {
                    lastStableTime = Date()
                }
            } else {
                lastStableTime = nil
            }
        } else {
            if result.state == .down && !isDown {
                isDown = true
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } else if result.state == .up && isDown {
                isDown = false
                repCount += 1
                GamificationManager.shared.addRep()
                WatchConnectivityManager.shared.sendExerciseDataToWatch(exerciseName: currentExercise.rawValue, repCount: repCount)
                SpeechManager.shared.speak("\(repCount)", force: true)
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            }
        }

        // Sesli geri bildirim mantığı
        if result.message != lastSpokenMessage {
            if result.message.contains("Mükemmel") || result.message.contains("Harika") ||
               result.message.contains("Çok fazla") || result.message.contains("Daha") ||
               result.message.contains("İyi") {
                SpeechManager.shared.speak(result.message)
                lastSpokenMessage = result.message
            }
        }
    }
}

