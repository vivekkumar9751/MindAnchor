import SwiftUI

struct IntentCaptureView: View {
    @Binding var navigationPath: NavigationPath
    var namespace: Namespace.ID?
    
    @State private var intentText: String = ""
    @State private var whyText: String = ""
    @State private var emotionalContext: String = ""
    @State private var selectedDurationIndex: Int = 1
    @AppStorage("focusPhilosophy") private var philosophyRaw: String = AnchorPhilosophy.undecided.rawValue
    
    private var philosophy: AnchorPhilosophy {
        AnchorPhilosophy(rawValue: philosophyRaw) ?? .undecided
    }
    
    let durations = [15, 30, 45, 60, 90, 120]
    
    var body: some View {
        ZStack {
            if let ns = namespace {
                Rectangle()
                    .fill(Color(UIColor.systemGroupedBackground))
                    .matchedGeometryEffect(id: "captureBackground", in: ns)
                    .ignoresSafeArea()
            }
            
            Form {
                // Philosophy context hint
                Section {
                    HStack(spacing: 10) {
                        Image(systemName: philosophy.icon)
                            .foregroundColor(philosophy.accentColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(philosophy.rawValue)
                                .font(.footnote)
                                .fontWeight(.semibold)
                            Text(philosophy.subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(philosophy.accentColor.opacity(0.06))
                }
                
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
        .scrollContentBackground(.hidden)
        .onAppear {
            // Pre-select duration index based on philosophy
            let defaultMinutes = Int(philosophy.defaultDurationSeconds / 60)
            selectedDurationIndex = durations.firstIndex(of: defaultMinutes) ?? 1
        }
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
