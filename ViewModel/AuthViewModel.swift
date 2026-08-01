import Foundation

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoginMode = true
    
    let firebaseManager: FirebaseManager
    
    init(firebaseManager: FirebaseManager) {
        self.firebaseManager = firebaseManager
    }
    
    func authenticate() {
        if isLoginMode {
            firebaseManager.signIn(email: email, password: password)
        } else {
            firebaseManager.signUp(email: email, password: password)
        }
    }
    
    func toggleMode() {
        isLoginMode.toggle()
    }
}
