import SwiftUI

struct ContextSnapshotView: View {
    @EnvironmentObject var intentManager: IntentManager
    var draft: DraftIntent
    @State private var nextStep: String = ""
    
    // We need to signal that we are done with the flow to the parent, 
    // but the IntentManager update handles the state switch in Content View.
    // So if we save to intentManager, ContentView will switch to AnchorView automatically?
    // That might be jarring if we are inside a NavigationStack.
    // Ideally, we reset the navigation stack OR the ContentView logic takes over.
    // If ContentView switches the "root" view based on state, the NavigationStack might disappear.
    // That effectively navigates us "Home".
    
    var body: some View {
        VStack(spacing: 24) {
            
            VStack(spacing: 8) {
                Text(draft.text)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(draft.why)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            
            VStack(alignment: .leading) {
                Text("What is the next small step?")
                    .font(.caption)
                    .foregroundColor(.secondary)
                TextField("E.g., Open the document", text: $nextStep)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            Spacer()
            
            Button(action: {
                let newIntent = Intent(
                    text: draft.text,
                    why: draft.why,
                    nextStep: nextStep,
                    status: .active,
                    emotionalContext: draft.emotionalContext,
                    estimatedDuration: draft.estimatedDuration
                )
                withAnimation {
                    intentManager.saveIntent(newIntent)
                }
            }) {
                Text("Anchor This Context")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(!nextStep.isEmpty ? Color.blue : Color.gray)
                    .cornerRadius(12)
            }
            .disabled(nextStep.isEmpty)
        }
        .padding()
    }
}
