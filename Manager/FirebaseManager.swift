import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import Combine

class FirebaseManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUserEmail = ""
    @Published var leaderboard: [LeaderboardUser] = []
    
    init() {
        // Oturum durumunu dinle
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                self.isAuthenticated = true
                self.currentUserEmail = user.email ?? ""
            } else {
                self.isAuthenticated = false
                self.currentUserEmail = ""
            }
        }
    }
    
    @Published var authError: String = ""
    @Published var showError: Bool = false
    @Published var successMessage: String = ""
    @Published var showSuccess: Bool = false
    
    // Kullanıcı Girişi
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.authError = error.localizedDescription
                    self.showError = true
                } else {
                    self.successMessage = "Başarıyla giriş yaptınız!"
                    self.showSuccess = true
                }
            }
        }
    }
    
    // Yeni Kullanıcı Kaydı
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.authError = error.localizedDescription
                    self.showError = true
                } else {
                    self.successMessage = "Başarıyla kayıt oldunuz! Aramıza hoş geldin."
                    self.showSuccess = true
                }
            }
        }
    }
    
    // Kullanıcının attığı adımları vb. veritabanına kaydet
    func saveUserData(steps: Double, runningMinutes: Double) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "steps": steps,
            "runningMinutes": runningMinutes,
            "lastUpdated": Timestamp(date: Date())
        ]
        
        db.collection("users").document(userId).setData(data, merge: true) { error in
            if let error = error {
                print("Veri kaydetme hatası: \(error.localizedDescription)")
            } else {
                print("Kullanıcı verileri başarıyla Firestore'a kaydedildi!")
                self.fetchLeaderboard() // Veri kaydettikten sonra listeyi yenile
            }
        }
    }
    
    // Firestore'dan liderlik tablosunu çek
    func fetchLeaderboard() {
        let db = Firestore.firestore()
        
        db.collection("users")
            .order(by: "steps", descending: true)
            .limit(to: 10)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Liderlik tablosu çekme hatası: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                var topUsers: [LeaderboardUser] = []
                for doc in documents {
                    let steps = doc.data()["steps"] as? Double ?? 0
                    let user = LeaderboardUser(id: doc.documentID, steps: steps)
                    topUsers.append(user)
                }
                
                DispatchQueue.main.async {
                    self.leaderboard = topUsers
                }
            }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Çıkış yapılırken hata oluştu")
        }
    }
}
