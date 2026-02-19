import SwiftUI

struct LaunchView: View {
    var onStartCapture: () -> Void
    var namespace: Namespace.ID?
    @State private var showAbout = false
    @AppStorage("focusPhilosophy") private var focusPhilosophy: String = "Mindful"
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var pulse: Bool = false
    
    let philosophies = ["Mindful", "Deep Work", "Flow"]
    
    var body: some View {
        ZStack {
            // Background ambient layer
            FluidGradientView()
                .ignoresSafeArea()
            
            if !hasOnboarded {
                onboardingView
            } else {
                mainLaunchView
            }
        }
    }
    
    var onboardingView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Welcome to MindAnchor")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Choose your focus philosophy:")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ForEach(philosophies, id: \.self) { philosophy in
                Button(action: {
                    focusPhilosophy = philosophy
                    withAnimation {
                        hasOnboarded = true
                    }
                }) {
                    Text(philosophy)
                        .font(.title3)
                        .fontWeight(.medium)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    var mainLaunchView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Main Interaction Area
            ZStack {
                // Pulsing Background (Subtle)
                // Respect Reduced Motion
                if !reduceMotion {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 250, height: 250)
                        .scaleEffect(pulse ? 1.1 : 1.0)
                        .opacity(pulse ? 0.5 : 0.3)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: pulse)
                        .onAppear { pulse = true }
                } else {
                    // Static fallback
                     Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 250, height: 250)
                        .opacity(0.4)
                }
                
                if let ns = namespace {
                    Circle()
                        .fill(.regularMaterial) // Glass effect
                        .frame(width: 200, height: 200)
                        .shadow(radius: 10)
                        .matchedGeometryEffect(id: "captureBackground", in: ns)
                } else {
                    Circle()
                        .fill(.regularMaterial)
                        .frame(width: 200, height: 200)
                        .shadow(radius: 10)
                }
                
                VStack(spacing: 16) {
                    // Use standard font styles for dynamic type support where possible
                    TypewriterText(text: "What's on your mind?", font: .headline, color: .primary)
                    
                    // The Plus Icon is strictly visual within the tappable area
                    Image(systemName: "plus")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.primary)
                        .opacity(0.7)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(Circle()) // Make the whole area tappable
            .onTapGesture {
                HapticManager.shared.playImpact(style: .medium)
                onStartCapture()
            }
            
            Spacer()
            
            Spacer()
            
            Button(action: { showAbout = true }) {
                Image(systemName: "info.circle")
                    .foregroundColor(.secondary)
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            
            // History Button
            HStack(spacing: 20) {
                NavigationLink(destination: IntentArchiveView()) {
                    VStack {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.title2)
                        Text("Journey")
                            .font(.caption2)
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .frame(width: 100)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }
                
                NavigationLink(destination: WidgetSimulatorView()) {
                    VStack {
                        Image(systemName: "square.dashed.inset.filled")
                            .font(.title2)
                        Text("Widgets")
                            .font(.caption2)
                    }
                    .foregroundColor(.primary)
                    .padding()
                    .frame(width: 100)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }
            }
            .padding(.bottom, 20)
        }
        .padding()
        .transition(.opacity)
    }
}
