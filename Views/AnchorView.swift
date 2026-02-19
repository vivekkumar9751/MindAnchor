import SwiftUI

struct AnchorView: View {
    @EnvironmentObject var intentManager: IntentManager
    @EnvironmentObject var soundManager: SoundManager
    let intent: Intent
    
    @State private var showInterruption = false
    @State private var vigilant = true
    @State private var breathing = false
    @AppStorage("focusPhilosophy") private var philosophyRaw: String = AnchorPhilosophy.undecided.rawValue
    
    private var philosophy: AnchorPhilosophy {
        AnchorPhilosophy(rawValue: philosophyRaw) ?? .undecided
    }
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            VStack(spacing: 24) {
                Spacer()
                
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
                    // Philosophy-specific ambient animation
                    PhilosophyVisualizationView(
                        style: philosophy.visualizationStyle,
                        accentColor: philosophy.accentColor,
                        progress: Double(progress(at: context.date))
                    )
                    .frame(width: 220, height: 220)
                    .accessibilityHidden(true)
                    
                    Circle()
                        .stroke(lineWidth: 15)
                        .opacity(0.1)
                        .foregroundColor(philosophy.accentColor)
                    
                    Circle()
                        .trim(from: 0.0, to: progress(at: context.date))
                        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                        .foregroundColor(progress(at: context.date) > 1.0 ? .red : philosophy.accentColor)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: progress(at: context.date))
                    
                    VStack {
                        Text(timerString(at: context.date))
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                            .accessibilityLabel("Time remaining: \(timerString(at: context.date))")
                        Text(progress(at: context.date) > 1.0 ? "Overtime" : "Remaining")
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
                    .accessibilityValue(soundManager.isPlaying ? "Playing \(soundManager.selectedSound)" : "Silent")
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
                    .accessibilityHint("Pause to log a distraction or handle functionality.")
                    .sheet(isPresented: $showInterruption) {
                        InterruptionView()
                    }
                    
                    HoldToCompleteButton(onComplete: {
                        withAnimation {
                            intentManager.markDone()
                        }
                    })
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
            .padding()
        }
    }
    
    // Timer Helpers
    func progress(at date: Date) -> CGFloat {
        guard let duration = intent.estimatedDuration, duration > 0 else { return 0 }
        let elapsed = date.timeIntervalSince(intent.createdAt)
        return CGFloat(elapsed / duration)
    }
    
    func timerString(at date: Date) -> String {
        let elapsed = date.timeIntervalSince(intent.createdAt)
        let duration = intent.estimatedDuration ?? 1800
        let remaining = max(0, duration - elapsed)
        
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
