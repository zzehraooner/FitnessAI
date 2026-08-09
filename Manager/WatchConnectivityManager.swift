import Foundation
import WatchConnectivity
import Combine

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()
    
    @Published var currentHeartRate: Double = 0.0
    
    private override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Oturum başarıyla aktive edildi
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) { }
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    
    // Uygulama mesaj aldığında
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let hr = message["heartRate"] as? Double {
                self.currentHeartRate = hr
            }
        }
    }
    
    // Telefon saat ile bir veri paylaşmak istediğinde
    func sendExerciseDataToWatch(exerciseName: String, repCount: Int) {
        if WCSession.default.isReachable {
            let message: [String: Any] = [
                "exerciseName": exerciseName,
                "repCount": repCount
            ]
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: nil)
        }
    }
}
