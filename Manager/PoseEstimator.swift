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
    
    private func analyzeForm() {
        let result: (percentage: Double, message: String, state: ExerciseState)
        
        switch currentExercise {
        case .squat:
            let hip = bodyPoints[.leftHip]
            let knee = bodyPoints[.leftKnee]
            let ankle = bodyPoints[.leftAnkle]
            result = ExerciseAnalyzer.analyzeSquat(hip: hip, knee: knee, ankle: ankle)
            
        case .pushup:
            let shoulder = bodyPoints[.leftShoulder]
            let elbow = bodyPoints[.leftElbow]
            let wrist = bodyPoints[.leftWrist]
            result = ExerciseAnalyzer.analyzePushup(shoulder: shoulder, elbow: elbow, wrist: wrist)
            
        case .lunge:
            let hip = bodyPoints[.leftHip]
            let knee = bodyPoints[.leftKnee]
            let ankle = bodyPoints[.leftAnkle]
            result = ExerciseAnalyzer.analyzeLunge(hip: hip, knee: knee, ankle: ankle)
            
        case .jumpingJacks:
            let hip = bodyPoints[.leftHip]
            let shoulder = bodyPoints[.leftShoulder]
            let wrist = bodyPoints[.leftWrist]
            result = ExerciseAnalyzer.analyzeJumpingJacks(hip: hip, shoulder: shoulder, wrist: wrist)
            
        case .situp:
            let shoulder = bodyPoints[.leftShoulder]
            let hip = bodyPoints[.leftHip]
            let knee = bodyPoints[.leftKnee]
            result = ExerciseAnalyzer.analyzeSitup(shoulder: shoulder, hip: hip, knee: knee)
            
        case .bicepCurl:
            let shoulder = bodyPoints[.leftShoulder]
            let elbow = bodyPoints[.leftElbow]
            let wrist = bodyPoints[.leftWrist]
            result = ExerciseAnalyzer.analyzeBicepCurl(shoulder: shoulder, elbow: elbow, wrist: wrist)
            
        case .shoulderPress:
            let shoulder = bodyPoints[.leftShoulder]
            let elbow = bodyPoints[.leftElbow]
            let wrist = bodyPoints[.leftWrist]
            result = ExerciseAnalyzer.analyzeShoulderPress(shoulder: shoulder, elbow: elbow, wrist: wrist)
            
        case .deadlift:
            let shoulder = bodyPoints[.leftShoulder]
            let hip = bodyPoints[.leftHip]
            let knee = bodyPoints[.leftKnee]
            result = ExerciseAnalyzer.analyzeDeadlift(shoulder: shoulder, hip: hip, knee: knee)
            
        case .highKnees:
            let shoulder = bodyPoints[.leftShoulder]
            let hip = bodyPoints[.leftHip]
            let knee = bodyPoints[.leftKnee]
            result = ExerciseAnalyzer.analyzeHighKnees(shoulder: shoulder, hip: hip, knee: knee)
            
        case .lateralRaises:
            let hip = bodyPoints[.leftHip]
            let shoulder = bodyPoints[.leftShoulder]
            let wrist = bodyPoints[.leftWrist]
            result = ExerciseAnalyzer.analyzeLateralRaises(hip: hip, shoulder: shoulder, wrist: wrist)
            
        case .gluteBridge:
            let shoulder = bodyPoints[.leftShoulder]
            let hip = bodyPoints[.leftHip]
            let knee = bodyPoints[.leftKnee]
            result = ExerciseAnalyzer.analyzeGluteBridge(shoulder: shoulder, hip: hip, knee: knee)
            
        case .calfRaises:
            let hip = bodyPoints[.leftHip]
            let knee = bodyPoints[.leftKnee]
            let ankle = bodyPoints[.leftAnkle]
            result = ExerciseAnalyzer.analyzeCalfRaises(hip: hip, knee: knee, ankle: ankle)
            
        case .tricepDips:
            let shoulder = bodyPoints[.leftShoulder]
            let elbow = bodyPoints[.leftElbow]
            let wrist = bodyPoints[.leftWrist]
            result = ExerciseAnalyzer.analyzeTricepDips(shoulder: shoulder, elbow: elbow, wrist: wrist)
            
        case .legRaises:
            let shoulder = bodyPoints[.leftShoulder]
            let hip = bodyPoints[.leftHip]
            let knee = bodyPoints[.leftKnee]
            result = ExerciseAnalyzer.analyzeLegRaises(shoulder: shoulder, hip: hip, knee: knee)
            
        case .frontRaises:
            let hip = bodyPoints[.leftHip]
            let shoulder = bodyPoints[.leftShoulder]
            let wrist = bodyPoints[.leftWrist]
            result = ExerciseAnalyzer.analyzeFrontRaises(hip: hip, shoulder: shoulder, wrist: wrist)
            
        case .mountainClimbers:
            let shoulder = bodyPoints[.leftShoulder]
            let hip = bodyPoints[.leftHip]
            let knee = bodyPoints[.leftKnee]
            result = ExerciseAnalyzer.analyzeMountainClimbers(shoulder: shoulder, hip: hip, knee: knee)
            
        case .donkeyKicks:
            let shoulder = bodyPoints[.leftShoulder]
            let hip = bodyPoints[.leftHip]
            let knee = bodyPoints[.leftKnee]
            result = ExerciseAnalyzer.analyzeDonkeyKicks(shoulder: shoulder, hip: hip, knee: knee)
            
        case .crunch:
            let shoulder = bodyPoints[.leftShoulder]
            let hip = bodyPoints[.leftHip]
            let knee = bodyPoints[.leftKnee]
            result = ExerciseAnalyzer.analyzeCrunch(shoulder: shoulder, hip: hip, knee: knee)
            
        case .bentOverRow:
            let shoulder = bodyPoints[.leftShoulder]
            let elbow = bodyPoints[.leftElbow]
            let wrist = bodyPoints[.leftWrist]
            result = ExerciseAnalyzer.analyzeBentOverRow(shoulder: shoulder, elbow: elbow, wrist: wrist)
            
        case .sumoSquat:
            let hip = bodyPoints[.leftHip]
            let knee = bodyPoints[.leftKnee]
            let ankle = bodyPoints[.leftAnkle]
            result = ExerciseAnalyzer.analyzeSumoSquat(hip: hip, knee: knee, ankle: ankle)
            
        case .goodMornings:
            let shoulder = bodyPoints[.leftShoulder]
            let hip = bodyPoints[.leftHip]
            let knee = bodyPoints[.leftKnee]
            result = ExerciseAnalyzer.analyzeGoodMornings(shoulder: shoulder, hip: hip, knee: knee)
            
        case .treePose:
            let hip = bodyPoints[.leftHip]
            let knee = bodyPoints[.leftKnee]
            let ankle = bodyPoints[.leftAnkle]
            result = ExerciseAnalyzer.analyzeTreePose(hip: hip, knee: knee, ankle: ankle)
            
        case .warriorPose:
            let hip = bodyPoints[.leftHip]
            let shoulder = bodyPoints[.leftShoulder]
            let wrist = bodyPoints[.leftWrist]
            result = ExerciseAnalyzer.analyzeWarriorPose(hip: hip, shoulder: shoulder, wrist: wrist)
        }
        
        self.formPercentage = result.percentage
        self.feedbackMessage = result.message
        
        // Tekrar veya Süre sayacı mantığı
        if currentExercise.isYoga {
            if result.state == .up {
                // Stabil duruşta süreyi (repCount) say
                if let lastStable = lastStableTime {
                    let elapsed = Date().timeIntervalSince(lastStable)
                    if elapsed >= 1.0 {
                        repCount += 1
                        GamificationManager.shared.addRep()
                        WatchConnectivityManager.shared.sendExerciseDataToWatch(exerciseName: currentExercise.rawValue, repCount: repCount)
                        lastStableTime = Date()
                        // Her 5 saniyede bir sesli bildirim yapalım
                        if repCount % 5 == 0 {
                            SpeechManager.shared.speak("\(repCount) saniye", force: true)
                        }
                    }
                } else {
                    lastStableTime = Date()
                }
            } else {
                // Denge bozulduğunda süreyi durdur
                lastStableTime = nil
            }
        } else {
            // Normal tekrar sayacı
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
            // Sadece önemli feedbackleri okumak için filtreleme yapabiliriz
            if result.message.contains("Mükemmel") || result.message.contains("Harika") || result.message.contains("Çok fazla") || result.message.contains("Daha") || result.message.contains("İyi") {
                SpeechManager.shared.speak(result.message)
                lastSpokenMessage = result.message
            }
        }
    }
}
