import SwiftUI

struct ReflectionView: View {
    @EnvironmentObject var intentManager: IntentManager
    @State private var reflectionText: String = ""
    
    @State private var showConfetti = true
    
    let emotions = ["Satisfied", "Relieved", "Drained", "Proud", "Neutral"]
    
    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Spacer()
                
                Text("Session Complete")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("How do you feel?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(emotions, id: \.self) { emotion in
                        ReflectionButton(title: emotion) { finish(emotion: emotion) }
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
                
                Text("You protected your focus today.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
            .padding()
            
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false) // Let user click buttons underneath
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
