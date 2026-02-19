import SwiftUI

struct LaunchView: View {
    var onStartCapture: () -> Void
    var namespace: Namespace.ID?
    @State private var showAbout = false
    @State private var showSettings = false
    @AppStorage("focusPhilosophy") private var philosophyRaw: String = AnchorPhilosophy.undecided.rawValue
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var pulse: Bool = false
    
    private var selectedPhilosophy: AnchorPhilosophy {
        AnchorPhilosophy(rawValue: philosophyRaw) ?? .undecided
    }
    
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
    
    // MARK: - Onboarding (Soft, No Pressure)
    
    var onboardingView: some View {
        VStack(spacing: 0) {
            Spacer()

            // Title
            VStack(spacing: 10) {
                Image(systemName: "anchor")
                    .font(.system(size: 44, weight: .light))
                    .foregroundColor(.primary)
                    .padding(.bottom, 8)
                
                Text("Welcome to MindAnchor")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("What feels right for you today?")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 40)
            
            // Philosophy Options
            VStack(spacing: 14) {
                ForEach(AnchorPhilosophy.allCases) { philosophy in
                    PhilosophyOptionCard(
                        philosophy: philosophy,
                        isSelected: philosophyRaw == philosophy.rawValue
                    ) {
                        philosophyRaw = philosophy.rawValue
                        HapticManager.shared.playImpact(style: .light)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                hasOnboarded = true
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 28)
            
            Spacer()
            
            // Skip prompt
            Button(action: {
                philosophyRaw = AnchorPhilosophy.undecided.rawValue
                withAnimation(.spring(response: 0.5)) {
                    hasOnboarded = true
                }
            }) {
                Text("Skip for now")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .underline()
            }
            .padding(.bottom, 32)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.97)))
    }
    
    // MARK: - Main Launch View
    
    var mainLaunchView: some View {
        VStack(spacing: 40) {
            // Top bar: info + settings
            HStack {
                Button(action: { showAbout = true }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .accessibilityLabel("About MindAnchor")
                
                Spacer()
                
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.secondary)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Settings")
            }
            .padding(.horizontal, 28)
            .padding(.top, 12)
            
            Spacer()
            
            // Main Interaction Area
            ZStack {
                if !reduceMotion {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 250, height: 250)
                        .scaleEffect(pulse ? 1.1 : 1.0)
                        .opacity(pulse ? 0.5 : 0.3)
                        .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: pulse)
                        .onAppear { pulse = true }
                } else {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 250, height: 250)
                        .opacity(0.4)
                }
                
                if let ns = namespace {
                    Circle()
                        .fill(.regularMaterial)
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
                    TypewriterText(text: "What's on your mind?", font: .headline, color: .primary)
                    Image(systemName: "plus")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.primary)
                        .opacity(0.7)
                        .accessibilityHidden(true)
                }
            }
            .contentShape(Circle())
            .onTapGesture {
                HapticManager.shared.playImpact(style: .medium)
                onStartCapture()
            }
            .accessibilityLabel("Set a new focus anchor")
            .accessibilityAddTraits(.isButton)
            
            Spacer()
            
            // Bottom Buttons
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
            .padding(.bottom, 28)
        }
        .transition(.opacity)
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}
