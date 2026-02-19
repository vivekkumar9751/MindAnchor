import SwiftUI

struct HoldToCompleteButton: View {
    var onComplete: () -> Void
    @State private var progress: CGFloat = 0.0
    @State private var isHolding = false
    @State private var timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State private var startTime: Date?
    
    // We only want the timer to fire when holding
    // But Timer.publish auto-connects. We can just ignore events if not holding.
    
    private let holdDuration: TimeInterval = 1.5
    
    var body: some View {
        ZStack {
            // Background
            Circle()
                .fill(Color.green.opacity(0.1))
                .frame(width: 80, height: 80)
                .scaleEffect(isHolding ? 1.1 : 1.0)
            
            // Progress Ring
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .foregroundColor(.green)
                .rotationEffect(Angle(degrees: -90))
                .frame(width: 80, height: 80)
            
            // Icon/Text
            Image(systemName: "checkmark")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(progress >= 1.0 ? .white : .green)
                .scaleEffect(progress >= 1.0 ? 1.2 : 1.0)
            
            // Interaction Handler
            Color.clear
                .contentShape(Circle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isHolding {
                                startHolding()
                            }
                        }
                        .onEnded { _ in
                            stopHolding()
                        }
                )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Complete Session")
        .accessibilityHint("Double tap and hold to finish your anchor.")
        .accessibilityAddTraits(.isButton)
        .onReceive(timer) { _ in
            guard isHolding, let start = startTime else { return }
            
            let elapsed = Date().timeIntervalSince(start)
            let newProgress = CGFloat(min(elapsed / holdDuration, 1.0))
            
            withAnimation(.linear(duration: 0.05)) {
                self.progress = newProgress
            }
            
            if newProgress >= 1.0 {
                complete()
            }
        }
    }
    
    private func startHolding() {
        isHolding = true
        startTime = Date()
        HapticManager.shared.playImpact(style: .light)
    }
    
    private func stopHolding() {
        isHolding = false
        startTime = nil
        withAnimation {
            progress = 0.0
        }
    }
    
    private func complete() {
        isHolding = false
        startTime = nil // Stop timer processing
        HapticManager.shared.playNotification(type: .success)
        onComplete()
    }
}
