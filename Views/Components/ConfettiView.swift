import SwiftUI

struct ConfettiView: View {
    let particles: [Particle]
    let startTime = Date()
    
    init() {
        // Create 50 random particles
        self.particles = (0..<50).map { _ in Particle() }
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSince(startTime)
                
                for particle in particles {
                    // Deterministic position
                    let x = particle.x + sin(time * 2 + particle.phase) * 0.1
                    let y = particle.y + (time * particle.speed)
                    
                    // Loop or disappear
                    // Let's loop for now (wrap around 1.0)
                    let loopedY = y.truncatingRemainder(dividingBy: 1.2) - 0.2
                    
                    let rect = CGRect(
                        x: x * size.width,
                        y: loopedY * size.height,
                        width: particle.size,
                        height: particle.size
                    )
                    
                    var contextCopy = context
                    contextCopy.translateBy(x: rect.midX, y: rect.midY)
                    contextCopy.rotate(by: particle.angle + .degrees(time * particle.spinSpeed))
                    contextCopy.translateBy(x: -rect.midX, y: -rect.midY)
                    
                    contextCopy.fill(Path(ellipseIn: rect), with: .color(particle.color))
                }
            }
        }
    }
}

struct Particle {
    var x: Double = Double.random(in: 0...1)
    var y: Double = Double.random(in: -0.2...0)
    var size: Double = Double.random(in: 5...12)
    var color: Color = [.red, .blue, .green, .yellow, .purple, .orange].randomElement()!
    var speed: Double = Double.random(in: 0.1...0.3) // Screen height fraction per second
    var angle: Angle = .degrees(Double.random(in: 0...360))
    var spinSpeed: Double = Double.random(in: 50...200)
    var phase: Double = Double.random(in: 0...10)
}
