import SwiftUI

/// A view that renders the appropriate ambient animation behind the focus timer
/// based on the user's selected philosophy.
struct PhilosophyVisualizationView: View {
    let style: PhilosophyVisualizationStyle
    let accentColor: Color
    let progress: Double
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    
    var body: some View {
        if reduceMotion {
            // Static fallback for all styles
            Circle()
                .fill(accentColor.opacity(0.08))
                .frame(width: 240, height: 240)
        } else {
            switch style {
            case .expandingCircle:
                ExpandingCircleView(color: accentColor)
            case .breathingWaves:
                BreathingWavesView(color: accentColor)
            case .floatingParticles:
                FloatingParticlesView(color: accentColor)
            case .growingLine:
                GrowingLineView(color: accentColor, progress: progress)
            }
        }
    }
}

// MARK: - Expanding Circle (Deep Work)

struct ExpandingCircleView: View {
    let color: Color
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .stroke(color.opacity(0.15 - Double(i) * 0.04), lineWidth: 2)
                    .scaleEffect(scale + CGFloat(i) * 0.12)
                    .animation(
                        .easeInOut(duration: 4)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.5),
                        value: scale
                    )
            }
            Circle()
                .fill(color.opacity(0.08))
                .scaleEffect(scale)
                .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: scale)
        }
        .frame(width: 240, height: 240)
        .onAppear { scale = 1.08 }
    }
}

// MARK: - Breathing Waves (Calm & Clarity)

struct BreathingWavesView: View {
    let color: Color
    @State private var phase: CGFloat = 0
    @State private var expanding = false
    
    var body: some View {
        ZStack {
            ForEach(0..<4, id: \.self) { i in
                Ellipse()
                    .stroke(color.opacity(0.12 - Double(i) * 0.02), lineWidth: 2)
                    .frame(
                        width: expanding ? 240 : 160,
                        height: expanding ? 60 + CGFloat(i) * 15 : 40 + CGFloat(i) * 10
                    )
                    .offset(y: CGFloat(i) * 6)
                    .animation(
                        .easeInOut(duration: 5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * 0.4),
                        value: expanding
                    )
            }
            Circle()
                .fill(color.opacity(0.06))
                .frame(width: expanding ? 200 : 160, height: expanding ? 200 : 160)
                .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: expanding)
        }
        .frame(width: 240, height: 240)
        .onAppear { expanding = true }
    }
}

// MARK: - Floating Particles (Creative Flow)

struct FloatingParticlesView: View {
    let color: Color
    @State private var particles: [ParticleData] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(color.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: particle.x, y: particle.y)
                    .animation(
                        .easeInOut(duration: particle.duration)
                        .repeatForever(autoreverses: true)
                        .delay(particle.delay),
                        value: particle.y
                    )
            }
        }
        .frame(width: 240, height: 240)
        .onAppear {
            particles = (0..<14).map { _ in ParticleData() }
        }
    }
}

struct ParticleData: Identifiable {
    let id = UUID()
    let x: CGFloat = CGFloat.random(in: -110...110)
    let y: CGFloat = CGFloat.random(in: -110...110)
    let size: CGFloat = CGFloat.random(in: 4...14)
    let opacity: Double = Double.random(in: 0.08...0.22)
    let duration: Double = Double.random(in: 3...7)
    let delay: Double = Double.random(in: 0...3)
}

// MARK: - Growing Line (Discipline)

struct GrowingLineView: View {
    let color: Color
    let progress: Double
    @State private var pulse = false
    
    var body: some View {
        ZStack {
            // Background track
            RoundedRectangle(cornerRadius: 4)
                .fill(color.opacity(0.1))
                .frame(width: 200, height: 8)
            
            // Growing fill
            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.4), color],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(8, CGFloat(progress) * 200), height: 8)
                    .animation(.linear(duration: 1), value: progress)
                Spacer(minLength: 0)
            }
            .frame(width: 200)
            
            // Steady pulse dot at current position
            Circle()
                .fill(color)
                .frame(width: 14, height: 14)
                .scaleEffect(pulse ? 1.3 : 1.0)
                .opacity(pulse ? 0.6 : 1.0)
                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                .offset(x: max(-93, CGFloat(progress) * 200 - 100))
        }
        .frame(width: 240, height: 240)
        .onAppear { pulse = true }
    }
}
