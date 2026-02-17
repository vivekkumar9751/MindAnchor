import SwiftUI

struct LaunchView: View {
    var onStartCapture: () -> Void
    @State private var showAbout = false
    @AppStorage("focusPhilosophy") private var focusPhilosophy: String = "Mindful"
    @AppStorage("hasOnboarded") private var hasOnboarded: Bool = false
    @State private var pulse: Bool = false
    
    let philosophies = ["Mindful", "Deep Work", "Flow"]
    
    var body: some View {
        ZStack {
            // Background ambient layer
            Color(UIColor.systemBackground)
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
                        .background(Color(UIColor.secondarySystemBackground))
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
            
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .scaleEffect(pulse ? 1.2 : 1.0)
                    .opacity(pulse ? 0.8 : 0.4)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                            pulse = true
                        }
                    }
                
                VStack(spacing: 16) {
                    Text("Hello, \(focusPhilosophy) Soul.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .kerning(2)
                    
                    Text("What’s on your mind?")
                        .font(.title2)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                }
            }
            
            Button(action: onStartCapture) {
                HStack {
                    Image(systemName: "plus")
                    Text("Anchor a Thought")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.3), radius: 5, x: 0, y: 5)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
            
            Spacer()
            
            Button(action: { showAbout = true }) {
                Image(systemName: "info.circle")
                    .foregroundColor(.gray)
                    .padding()
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
        }
        .padding()
        .transition(.opacity)
    }
}
