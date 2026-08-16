import SwiftUI
import WatchConnectivity
import HealthKit

// MARK: - Watch Oturum Yöneticisi

class WatchSessionManager: NSObject, ObservableObject, WCSessionDelegate {
    @Published var exerciseName: String = "FitnessAI"
    @Published var repCount: Int = 0
    @Published var formPercentage: Double = 0
    @Published var isResting: Bool = false
    @Published var nextExercise: String? = nil
    @Published var routineFinished: Bool = false
    @Published var totalReps: Int = 0

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) { }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let name = message["exerciseName"] as? String { self.exerciseName = name }
            if let reps = message["repCount"] as? Int { self.repCount = reps }
            if let form = message["formPercentage"] as? Double { self.formPercentage = form }
            if let rest = message["isResting"] as? Bool { self.isResting = rest }
            if let next = message["nextExercise"] as? String { self.nextExercise = next }
            if let finished = message["routineFinished"] as? Bool, finished {
                self.routineFinished = true
                self.totalReps = message["totalReps"] as? Int ?? 0
            }

            // Nabız ve kalori telefona geri gönder (simüle)
            WCSession.default.sendMessage([
                "heartRate": 72.0 + Double.random(in: -5...5),
                "calories": Double.random(in: 100...200)
            ], replyHandler: nil, errorHandler: nil)
        }
    }
}

// MARK: - Watch Ana Görünüm

struct WatchContentView: View {
    @StateObject var manager = WatchSessionManager()

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            if manager.routineFinished {
                completionView
            } else if manager.isResting {
                restView
            } else {
                activeView
            }
        }
    }

    // MARK: Aktif

    private var activeView: some View {
        VStack(spacing: 6) {
            Text(manager.exerciseName)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.gray)
                .lineLimit(1).minimumScaleFactor(0.6)

            Text("\(manager.repCount)")
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .foregroundColor(.white)

            Text("tekrar")
                .font(.caption2)
                .foregroundColor(.gray)

            if manager.formPercentage > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "figure.arms.open").font(.caption2)
                    Text(String(format: "%.0f%%", manager.formPercentage)).font(.caption.bold())
                }
                .foregroundColor(formColor)
                .padding(.horizontal, 10).padding(.vertical, 3)
                .background(formColor.opacity(0.2))
                .cornerRadius(8)
            }
        }
        .padding()
    }

    // MARK: Dinlenme

    private var restView: some View {
        VStack(spacing: 6) {
            Text("DİNLENME")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.cyan)

            Image(systemName: "timer")
                .font(.system(size: 28))
                .foregroundColor(.cyan)

            if let next = manager.nextExercise {
                Text(next)
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }

    // MARK: Tamamlandı

    private var completionView: some View {
        VStack(spacing: 6) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 28))
                .foregroundColor(.yellow)
            Text("Tamamlandı!")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            Text("\(manager.totalReps) tekrar")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }

    private var formColor: Color {
        manager.formPercentage >= 90 ? .green : manager.formPercentage >= 70 ? .yellow : .orange
    }
}


