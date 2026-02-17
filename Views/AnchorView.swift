import SwiftUI

struct AnchorView: View {
    @EnvironmentObject var intentManager: IntentManager
    let intent: Intent
    
    @State private var showInterruption = false
    @State private var vigilant = true // Simulated Focus Mode state
    
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
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                .shadow(radius: 3)
                
                // Focus Timer Visualization
                ZStack {
                    Circle()
                        .stroke(lineWidth: 15)
                        .opacity(0.1)
                        .foregroundColor(.blue)
                    
                    Circle()
                        .trim(from: 0.0, to: progress(at: context.date))
                        .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                        .foregroundColor(progress(at: context.date) > 1.0 ? .red : .blue)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: progress(at: context.date))
                    
                    VStack {
                        Text(timerString(at: context.date))
                            .font(.system(size: 40, weight: .bold, design: .monospaced))
                        Text(progress(at: context.date) > 1.0 ? "Overtime" : "Remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 200, height: 200)
                .padding(.vertical)
                
                // Focus Mode Toggle (Visual)
                Toggle("Focus Mode Active", isOn: $vigilant)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
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
                    .sheet(isPresented: $showInterruption) {
                        InterruptionView()
                    }
                    
                    Button(action: {
                        withAnimation {
                            intentManager.markDone()
                        }
                    }) {
                        VStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                            Text("Complete")
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                    }
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
        let duration = intent.estimatedDuration ?? 1800 // Default 30 min
        let remaining = max(0, duration - elapsed)
        
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
