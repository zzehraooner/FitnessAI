import Foundation
import WatchConnectivity
import Combine

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()

    @Published var currentHeartRate: Double = 0.0
    @Published var currentCalories: Double = 0.0
    @Published var isWatchReachable: Bool = false

    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    // MARK: - WCSessionDelegate

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) { }

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isWatchReachable = session.isReachable
        }
    }

    // Watch → Telefon: nabız ve kalori
    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let hr = message["heartRate"] as? Double {
                self.currentHeartRate = hr
            }
            if let cal = message["calories"] as? Double {
                self.currentCalories = cal
            }
        }
    }

    // MARK: - Telefon → Watch Gönderimler

    /// Egzersiz adı ve tekrar sayısını Watch'a gönder
    func sendExerciseDataToWatch(exerciseName: String, repCount: Int) {
        guard WCSession.default.isReachable else { return }
        let message: [String: Any] = [
            "exerciseName": exerciseName,
            "repCount": repCount
        ]
        WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }

    /// Form yüzdesi, dinlenme durumu ve sıradaki egzersiz adını Watch'a gönder
    func sendFormDataToWatch(formPercentage: Double, isResting: Bool, nextExercise: String? = nil) {
        guard WCSession.default.isReachable else { return }
        var message: [String: Any] = [
            "formPercentage": formPercentage,
            "isResting": isResting
        ]
        if let next = nextExercise {
            message["nextExercise"] = next
        }
        WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }

    /// Rutin tamamlandı bildirimi
    func sendRoutineFinishedToWatch(totalReps: Int, totalMinutes: Int) {
        guard WCSession.default.isReachable else { return }
        let message: [String: Any] = [
            "routineFinished": true,
            "totalReps": totalReps,
            "totalMinutes": totalMinutes
        ]
        WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
}
