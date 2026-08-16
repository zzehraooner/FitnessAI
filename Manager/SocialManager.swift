import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth

struct LeaderboardEntry: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let userName: String
    let totalXP: Int
    let level: Int
    let avatarIcon: String
}

class SocialManager: ObservableObject {
    static let shared = SocialManager()
    
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var friends: [LeaderboardEntry] = []
    
    private let db = Firestore.firestore()
    
    private init() {}
    
    // MARK: - Global Liderlik Tablosu
    
    func fetchLeaderboard() {
        // Dummy data for fallback/preview
        let dummyData = [
            LeaderboardEntry(id: "1", userId: "user1", userName: "Zehra O.", totalXP: 4500, level: 15, avatarIcon: "person.fill"),
            LeaderboardEntry(id: "2", userId: "user2", userName: "Ahmet Y.", totalXP: 4200, level: 14, avatarIcon: "person.circle.fill"),
            LeaderboardEntry(id: "3", userId: "user3", userName: "Elif B.", totalXP: 3800, level: 13, avatarIcon: "star.fill"),
            LeaderboardEntry(id: "4", userId: "user4", userName: "Can T.", totalXP: 3100, level: 11, avatarIcon: "bolt.fill")
        ]
        
        db.collection("users")
            .order(by: "totalXP", descending: true)
            .limit(to: 20)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Leaderboard fetch error: \(error)")
                    // Hata durumunda (Örn: Firestore yetkisi yoksa) dummy veriyi göster
                    if self.leaderboard.isEmpty {
                        DispatchQueue.main.async { self.leaderboard = dummyData }
                    }
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    DispatchQueue.main.async { self.leaderboard = dummyData }
                    return
                }
                
                let entries: [LeaderboardEntry] = documents.compactMap { doc in
                    let data = doc.data()
                    return LeaderboardEntry(
                        id: doc.documentID,
                        userId: doc.documentID,
                        userName: data["userName"] as? String ?? "Anonim",
                        totalXP: data["totalXP"] as? Int ?? 0,
                        level: data["level"] as? Int ?? 1,
                        avatarIcon: data["avatarIcon"] as? String ?? "person.circle.fill"
                    )
                }
                
                DispatchQueue.main.async {
                    self.leaderboard = entries
                }
            }
    }
    
    // MARK: - Update User Score
    
    func syncMyScore(totalXP: Int, level: Int, userName: String) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users").document(userId).setData([
            "userName": userName,
            "totalXP": totalXP,
            "level": level,
            "lastActive": FieldValue.serverTimestamp()
        ], merge: true) { error in
            if let error = error {
                print("Error syncing score: \(error)")
            }
        }
    }
}
