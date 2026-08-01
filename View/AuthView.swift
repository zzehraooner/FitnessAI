import SwiftUI

struct AuthView: View {
    @StateObject private var viewModel: AuthViewModel
    
    init(firebaseManager: FirebaseManager) {
        _viewModel = StateObject(wrappedValue: AuthViewModel(firebaseManager: firebaseManager))
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                // Logo ve Başlık
                VStack(spacing: 15) {
                    Image(systemName: "figure.mind.and.body")
                        .font(.system(size: 80))
                        .foregroundColor(.cyan)
                    
                    Text("FitnessAI")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                    
                    Text(viewModel.isLoginMode ? "Hesabınıza giriş yapın" : "Yeni bir hesap oluşturun")
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                
                // Form Alanı
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.gray)
                        TextField("E-posta adresi", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                    
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                        SecureField("Şifre", text: $viewModel.password)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                
                // Aksiyon Butonu
                Button(action: {
                    viewModel.authenticate()
                }) {
                    Text(viewModel.isLoginMode ? "Giriş Yap" : "Kayıt Ol")
                        .font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.cyan)
                        .cornerRadius(15)
                        .shadow(color: .cyan.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 30)
                
                // Mod Değiştirici
                Button(action: {
                    withAnimation {
                        viewModel.toggleMode()
                    }
                }) {
                    Text(viewModel.isLoginMode ? "Hesabınız yok mu? **Kayıt Ol**" : "Zaten hesabınız var mı? **Giriş Yap**")
                        .font(.footnote)
                        .foregroundColor(.cyan)
                }
                .padding(.top, 10)
                
                Spacer()
            }
        }
    }
}
