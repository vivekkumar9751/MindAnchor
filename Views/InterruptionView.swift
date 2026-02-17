import SwiftUI

struct InterruptionView: View {
    @EnvironmentObject var intentManager: IntentManager
    @Environment(\.dismiss) var dismiss
    
    @State private var distractionText: String = ""
    @State private var showDistractionInput: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            if showDistractionInput {
                distractionInputView
            } else {
                choiceView
            }
        }
        .padding()
        .presentationDetents([.fraction(0.4), .medium])
    }
    
    var choiceView: some View {
        VStack(spacing: 20) {
            Text("Interruption Detected")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Is this urgent, or is your mind wandering?")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Button(action: {
                    // Urgent -> Pause
                    withAnimation {
                        intentManager.pauseIntent()
                        dismiss()
                    }
                }) {
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.largeTitle)
                        Text("Urgent Life Stuff")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(12)
                    .foregroundColor(.orange)
                }
                
                Button(action: {
                    // Avoidance -> Capture Distraction
                    withAnimation {
                        showDistractionInput = true
                    }
                }) {
                    VStack {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                            .font(.largeTitle)
                        Text("Just a Distraction")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(12)
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    var distractionInputView: some View {
        VStack(spacing: 20) {
            Text("Capture the Distraction")
                .font(.headline)
            
            TextField("What's pulling you away?", text: $distractionText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button("Cancel") {
                    withAnimation {
                        showDistractionInput = false
                    }
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Button("Capture & Return") {
                    if !distractionText.isEmpty {
                        intentManager.logDistraction(distractionText)
                    }
                    dismiss()
                }
                .fontWeight(.bold)
                .disabled(distractionText.isEmpty)
            }
            .padding(.horizontal)
        }
    }
}
