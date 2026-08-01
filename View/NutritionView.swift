import SwiftUI

struct NutritionView: View {
    @State private var waterGlasses: Int = 0
    @State private var dailyCalories: Double = 0
    
    // Basit kalori ekleme listesi
    let foodOptions = [
        ("Sağlıklı Kahvaltı", 350.0, "🍳"),
        ("Tavuk Salata", 450.0, "🥗"),
        ("Protein Shake", 200.0, "🥤"),
        ("Muz & Fıstık Ezmesi", 250.0, "🍌")
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Başlık
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Beslenme & Su")
                                .font(.largeTitle)
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                            Text("Bugün vücuduna ne kadar iyi baktın?")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Su Takibi (Hydration)
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.cyan)
                                    .font(.title2)
                                Text("Su Takibi")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("\(waterGlasses) / 8 Bardak")
                                    .foregroundColor(.gray)
                            }
                            
                            HStack(spacing: 10) {
                                ForEach(0..<8) { index in
                                    Image(systemName: index < waterGlasses ? "drop.fill" : "drop")
                                        .foregroundColor(.cyan)
                                        .font(.title2)
                                        .scaleEffect(index < waterGlasses ? 1.2 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: waterGlasses)
                                        .onTapGesture {
                                            if waterGlasses == index {
                                                waterGlasses -= 1
                                            } else {
                                                waterGlasses = index + 1
                                            }
                                        }
                                }
                            }
                            .padding()
                            .background(Color.cyan.opacity(0.1))
                            .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        
                        // Kalori Alımı (Nutrition)
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: "fork.knife")
                                    .foregroundColor(.green)
                                    .font(.title2)
                                Text("Alınan Kalori")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                                Text(String(format: "%.0f kcal", dailyCalories))
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            
                            VStack(spacing: 10) {
                                ForEach(foodOptions, id: \.0) { food in
                                    Button(action: {
                                        withAnimation(.spring()) {
                                            dailyCalories += food.1
                                        }
                                    }) {
                                        HStack {
                                            Text(food.2)
                                                .font(.title)
                                            Text(food.0)
                                                .foregroundColor(.white)
                                                .fontWeight(.semibold)
                                            Spacer()
                                            Text("+\(Int(food.1)) kcal")
                                                .foregroundColor(.green)
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.green)
                                        }
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .cornerRadius(15)
                                    }
                                }
                                
                                Button(action: {
                                    withAnimation { dailyCalories = 0 }
                                }) {
                                    Text("Kaloriyi Sıfırla")
                                        .foregroundColor(.red)
                                        .padding(.top, 10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}
