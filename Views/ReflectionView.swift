import SwiftUI

struct ReflectionView: View {
    @EnvironmentObject var intentManager: IntentManager
    @State private var reflectionText: String = ""
    @State private var showConfetti = true
    @AppStorage("focusPhilosophy") private var philosophyRaw: String = AnchorPhilosophy.undecided.rawValue
    
    private var philosophy: AnchorPhilosophy {
        AnchorPhilosophy(rawValue: philosophyRaw) ?? .undecided
    }
    
    let emotions = ["Satisfied", "Relieved", "Drained", "Proud", "Neutral"]
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                
                // Philosophy-aware header
                VStack(spacing: 8) {
                    Text("Session Complete")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    // Microcopy driven by philosophy
                    Text(philosophy.completionMessage)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(philosophy.accentColor)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    
                    Text("How do you feel?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(emotions, id: \.self) { emotion in
                        ReflectionButton(title: emotion, accentColor: philosophy.accentColor) {
                            finish(emotion: emotion)
                        }
                    }
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("What did you learn? (Optional)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Type here...", text: $reflectionText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Philosophy-aware bottom tag
                Text(philosophy.narrativeTone)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
            .padding()
            
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation {
                                showConfetti = false
                            }
                        }
                    }
            }
        }
    }
    
    func finish(emotion: String) {
        withAnimation {
            intentManager.completeIntent(emotion: emotion, reflection: reflectionText)
        }
    }
}

struct ReflectionButton: View {
    let title: String
    var accentColor: Color = .primary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
        }
    }
}
