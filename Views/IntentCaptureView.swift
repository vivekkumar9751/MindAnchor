import SwiftUI

struct IntentCaptureView: View {
    @Binding var navigationPath: NavigationPath
    var namespace: Namespace.ID?
    
    @State private var intentText: String = ""
    @State private var whyText: String = ""
    @State private var emotionalContext: String = ""
    @State private var selectedDurationIndex: Int = 1
    
    let durations = [15, 30, 45, 60, 90, 120]
    
    var body: some View {
        ZStack {
            if let ns = namespace {
                Rectangle()
                    .fill(Color(UIColor.systemGroupedBackground)) // Match form background
                    .matchedGeometryEffect(id: "captureBackground", in: ns)
                    .ignoresSafeArea()
            }
            
            Form {
            Section(header: Text("Inception")) {
                TextField("What are you doing?", text: $intentText)
                TextField("Why? (Logical reason)", text: $whyText)
            }
            
            Section(header: Text("Depth")) {
                TextField("Emotional Context (Why it matters?)", text: $emotionalContext)
                
                Picker("Expected Duration", selection: $selectedDurationIndex) {
                    ForEach(0..<durations.count, id: \.self) { index in
                        Text("\(durations[index]) min").tag(index)
                    }
                }
            }
            
            Section {
                Button(action: {
                    let draft = DraftIntent(
                        text: intentText,
                        why: whyText,
                        emotionalContext: emotionalContext,
                        estimatedDuration: TimeInterval(durations[selectedDurationIndex] * 60)
                    )
                    navigationPath.append(draft)
                }) {
                    Text("Continue to Anchor")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(!isFormValid)
            }
        }
        }
        .navigationTitle("New Anchor")
        .scrollContentBackground(.hidden) // Important for ZStack background to show
    }
    
    var isFormValid: Bool {
        return !intentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !whyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// Temporary data structure for the flow
struct DraftIntent: Hashable {
    var text: String
    var why: String
    var emotionalContext: String
    var estimatedDuration: TimeInterval
}
