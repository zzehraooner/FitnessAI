import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct LeaderboardUser: Identifiable {
    let id: String
    let steps: Double
}

struct LeaderboardView: View {
    @ObservedObject var firebaseManager: FirebaseManager
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Liderlik Tablosu")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .padding(.top, 30)
                
                Text("En çok adım atanlar")
                    .foregroundColor(.gray)
                    .padding(.bottom, 20)
                
                if firebaseManager.leaderboard.isEmpty {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                        .scaleEffect(2)
                    Text("Veriler yükleniyor...")
                        .foregroundColor(.gray)
                        .padding(.top)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(Array(firebaseManager.leaderboard.enumerated()), id: \.element.id) { index, user in
                                HStack {
                                    Text("\(index + 1)")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(index == 0 ? .yellow : (index == 1 ? .gray : (index == 2 ? .orange : .white)))
                                        .frame(width: 30)
                                    
                                    Image(systemName: "person.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.cyan)
                                    
                                    Text(user.id == Auth.auth().currentUser?.uid ? "Ben" : "Kullanıcı")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(user.steps))")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                    
                                    Text("adım")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(user.id == Auth.auth().currentUser?.uid ? Color.cyan : Color.clear, lineWidth: 2)
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            firebaseManager.fetchLeaderboard()
        }
    }
}
