import SwiftUI

struct AnchorView: View {
    @EnvironmentObject var intentManager: IntentManager
    @EnvironmentObject var soundManager: SoundManager
    let intent: Intent
    
    @State private var showInterruption = false
    @State private var vigilant = true
    @State private var breathing = false
    @State private var overtimeHapticTimer: Timer? = nil
    @State private var isInOvertime = false
    @AppStorage("hapticFeedback") private var hapticFeedback: Bool = true
    @AppStorage("focusPhilosophy") private var philosophyRaw: String = AnchorPhilosophy.undecided.rawValue
    
    private var philosophy: AnchorPhilosophy {
        AnchorPhilosophy(rawValue: philosophyRaw) ?? .undecided
    }
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let currentProgress = Double(progress(at: context.date))
            
            VStack(spacing: 24) {
                Spacer()
                
                // Overtime banner
                if currentProgress >= 1.0 {
                    HStack(spacing: 8) {
                        Image(systemName: "timer.circle.fill")
                            .foregroundColor(.white)
                        Text("Session complete — tap the button below!")
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.85))
                    .cornerRadius(12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Thought Card (Compact)
                VStack(spacing: 12) {
                    Text(intent.text)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    if let step = intent.nextStep {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text(step)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(philosophy.accentColor)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.regularMaterial)
                .cornerRadius(16)
                .shadow(radius: 3)
                
                // Focus Timer Visualization
                ZStack {
                    PhilosophyVisualizationView(
                        style: philosophy.visualizationStyle,
                        accentColor: currentProgress >= 1.0 ? .red : philosophy.accentColor,
                        progress: currentProgress
                    )
                    .frame(width: 220, height: 220)
                    .accessibilityHidden(true)
                    
                    Circle()
                        .stroke(lineWidth: 15)
                        .opacity(0.1)
                        .foregroundColor(currentProgress >= 1.0 ? .red : philosophy.accentColor)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(currentProgress, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                        .foregroundColor(currentProgress >= 1.0 ? .red : philosophy.accentColor)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: currentProgress)
                    
                    VStack {
                        Text(timerString(at: context.date))
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .foregroundColor(currentProgress >= 1.0 ? .red : .primary)
                            .accessibilityLabel("Time remaining: \(timerString(at: context.date))")
                        Text(currentProgress >= 1.0 ? "Overtime" : "Remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)
                    }
                }
                .frame(width: 200, height: 200)
                .padding(.vertical)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Focus Timer. \(timerString(at: context.date)) remaining.")
                
                // Focus Mode & Ambient Controls
                HStack {
                    Toggle("Focus Mode", isOn: $vigilant)
                        .labelsHidden()
                        .accessibilityLabel("Toggle Focus Mode")
                        .accessibilityHint("Enables visual breathing guide.")
                    Text("Focus Mode")
                        .font(.caption)
                        .accessibilityHidden(true)
                    
                    Spacer()
                    
                    Button(action: {
                        soundManager.toggleSound()
                    }) {
                        HStack {
                            Image(systemName: soundManager.isPlaying ? "speaker.wave.2.fill" : "speaker.slash.fill")
                            Text(soundManager.isPlaying ? soundManager.selectedSound : "Silent")
                        }
                        .font(.caption)
                        .padding(8)
                        .background(.ultraThinMaterial)
                        .cornerRadius(8)
                    }
                    .accessibilityLabel(soundManager.isPlaying ? "Mute Sound" : "Play Sound")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                HStack(spacing: 20) {
                    Button(action: {
                        showInterruption = true
                    }) {
                        VStack {
                            Image(systemName: "pause.circle.fill")
                                .font(.title)
                            Text("Interrupt")
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(12)
                    }
                    .accessibilityLabel("Interrupt Session")
                    .sheet(isPresented: $showInterruption) {
                        InterruptionView()
                    }
                    
                    HoldToCompleteButton(onComplete: {
                        stopOvertimeHaptics()
                        withAnimation {
                            intentManager.markDone()
                        }
                    })
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
            .padding()
            // Watch for overtime crossing
            .onChange(of: currentProgress >= 1.0) { nowOvertime in
                if nowOvertime && !isInOvertime {
                    isInOvertime = true
                    startOvertimeHaptics()
                }
            }
        }
        .onDisappear {
            stopOvertimeHaptics()
        }
    }
    
    // MARK: - Overtime Haptics
    
    private func startOvertimeHaptics() {
        guard hapticFeedback else { return }
        // Fire immediately on crossing
        triggerOvertimeHaptic()
        // Then repeat every 8 seconds until user acts
        overtimeHapticTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            triggerOvertimeHaptic()
        }
    }
    
    private func triggerOvertimeHaptic() {
        guard hapticFeedback else { return }
        // Triple notification haptic — distinct from regular interaction haptics
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            generator.notificationOccurred(.warning)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            generator.notificationOccurred(.success)
        }
    }
    
    private func stopOvertimeHaptics() {
        overtimeHapticTimer?.invalidate()
        overtimeHapticTimer = nil
        isInOvertime = false
    }
    
    // MARK: - Timer Helpers
    
    func progress(at date: Date) -> CGFloat {
        guard let duration = intent.estimatedDuration, duration > 0 else { return 0 }
        let elapsed = date.timeIntervalSince(intent.createdAt)
        return CGFloat(elapsed / duration)
    }
    
    func timerString(at date: Date) -> String {
        let elapsed = date.timeIntervalSince(intent.createdAt)
        let duration = intent.estimatedDuration ?? 1800
        let remaining = duration - elapsed
        
        if remaining <= 0 {
            // Show overtime duration
            let overtime = Int(-remaining)
            let m = overtime / 60
            let s = overtime % 60
            return "+\(String(format: "%02d:%02d", m, s))"
        }
        
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
