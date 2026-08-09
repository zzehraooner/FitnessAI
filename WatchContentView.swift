import SwiftUI
import WatchConnectivity
import HealthKit

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var exerciseName: String = "Bekleniyor..."
    @Published var repCount: Int = 0
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let name = message["exerciseName"] as? String {
                self.exerciseName = name
            }
            if let count = message["repCount"] as? Int {
                self.repCount = count
                // Titreşim (Haptic) vererek kullanıcıyı uyar
                WKInterfaceDevice.current().play(.success)
            }
        }
    }
}

struct WatchContentView: View {
    @StateObject var sessionManager = WatchSessionManager()
    
    // Basit bir nabız mock'u (Gerçek uygulamada HealthKit HKWorkoutSession kullanılır)
    @State private var heartRate: Int = 110
    
    var body: some View {
        VStack(spacing: 15) {
            
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("\(heartRate) BPM")
                    .font(.headline)
            }
            
            Divider()
            
            Text(sessionManager.exerciseName.uppercased())
                .font(.footnote)
                .foregroundColor(.cyan)
            
            Text("\(sessionManager.repCount)")
                .font(.system(size: 50, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Tekrar")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
