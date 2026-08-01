import SwiftUI

// Saf SwiftUI Konfeti (Lottie yerine)
struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var color: Color
    var scale: CGFloat
    var opacity: Double
}

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .cyan, .pink]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Rectangle()
                        .fill(particle.color)
                        .frame(width: 8, height: 16)
                        .scaleEffect(particle.scale)
                        .rotationEffect(.degrees(particle.rotation))
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                createParticles(in: geometry.size)
            }
        }
    }
    
    func createParticles(in size: CGSize) {
        // 100 Adet konfeti üret
        for _ in 0..<100 {
            let startX = CGFloat.random(in: 0...size.width)
            let startY = CGFloat.random(in: -50...0)
            
            let particle = ConfettiParticle(
                x: startX,
                y: startY,
                rotation: Double.random(in: 0...360),
                color: colors.randomElement()!,
                scale: CGFloat.random(in: 0.5...1.5),
                opacity: 1.0
            )
            particles.append(particle)
        }
        
        // Animasyonu başlat (Aşağı doğru düşme)
        withAnimation(.timingCurve(0.1, 0.8, 0.2, 1, duration: 3.0)) {
            for i in 0..<particles.count {
                particles[i].y += CGFloat.random(in: size.height...size.height + 200)
                particles[i].rotation += Double.random(in: 180...720)
                particles[i].opacity = 0
            }
        }
    }
}
