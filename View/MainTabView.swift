import SwiftUI

struct MainTabView: View {
    @StateObject var firebaseManager = FirebaseManager()
    @StateObject var storeManager = StoreManager()
    
    var body: some View {
        Group {
            if firebaseManager.isAuthenticated {
                TabView {
                DashboardView(firebaseManager: firebaseManager)
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Özet")
                    }
                
                NutritionView()
                    .tabItem {
                        Image(systemName: "fork.knife")
                        Text("Beslenme")
                    }
                
                WorkoutRoutineView(storeManager: storeManager)
                    .tabItem {
                        Image(systemName: "figure.highintensity.intervaltraining")
                        Text("Rutinler")
                    }
                
                HomeView()
                    .tabItem {
                        Image(systemName: "camera.metering.center.weighted")
                        Text("AI Studio")
                    }
                
                LeaderboardView(firebaseManager: firebaseManager)
                    .tabItem {
                        Image(systemName: "trophy.fill")
                        Text("Liderlik")
                    }
                
                NavigationView {
                    VStack(spacing: 20) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.gray)
                        
                        Text(firebaseManager.currentUserEmail)
                            .font(.title)
                            .foregroundColor(.white)
                            
                        NavigationLink(destination: BadgesView()) {
                            HStack {
                                Image(systemName: "rosette")
                                Text("Rozetlerim ve Başarılarım")
                            }
                            .font(.headline)
                            .foregroundColor(.orange)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                        
                        Button(action: {
                            firebaseManager.logout()
                        }) {
                            Text("Çıkış Yap")
                                .foregroundColor(.red)
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                    .navigationTitle("Profil")
                }
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profil")
                }
            }
            .accentColor(.cyan)
        } else {
            AuthView(firebaseManager: firebaseManager)
        }
        }
        .alert("Hata", isPresented: $firebaseManager.showError) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(firebaseManager.authError)
        }
        .alert("Başarılı", isPresented: $firebaseManager.showSuccess) {
            Button("Tamam", role: .cancel) { }
        } message: {
            Text(firebaseManager.successMessage)
        }
    }
}
