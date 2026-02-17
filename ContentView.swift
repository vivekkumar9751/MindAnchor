import SwiftUI

struct ContentView: View {
    @EnvironmentObject var intentManager: IntentManager
    @State private var navigationPath = NavigationPath()
    @State private var isCapturing = false
    
    // We treat the "Capture Flow" as a modal or navigation push on top of a base view?
    // Or we switch the whole view hierarchy?
    // User Flow:
    // Launch -> Capture -> Snapshot -> Anchor
    // Anchor -> Done -> Reflection -> Empty
    // Empty -> Capture -> ...
    
    // BUT: Launch, Return, Anchor, Reflection, Empty are all "Root" states.
    // The "Transition" is the only time we might use navigation pushes (Capture -> Snapshot).
    
    var body: some View {
        // If we represent the Capture Flow as a separate mode
        if isCapturing {
            NavigationStack(path: $navigationPath) {
                IntentCaptureView(navigationPath: $navigationPath)
                    .navigationTitle("New Anchor")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isCapturing = false
                            }
                        }
                    }
                    .navigationDestination(for: DraftIntent.self) { draft in
                        ContextSnapshotView(draft: draft)
                    }
            }
            .onChange(of: intentManager.currentIntent) { newValue in
                if newValue != nil {
                    // Intent was saved! Exit capture mode.
                    isCapturing = false
                }
            }
        } else {
            // Main State Switcher
            Group {
                if let intent = intentManager.currentIntent {
                    switch intent.status {
                    case .active:
                        AnchorView(intent: intent)
                    case .paused:
                        ReturnView(intent: intent)
                    case .completed:
                        ReflectionView()
                    }
                } else {
                    // No intent
                    // Use NavigationStack here? 
                    // Wait, if EmptyState has a button to "Capture", it can just set isCapturing = true.
                    // But "LaunchView" is special: "if noIntent { show LaunchScreen }"
                    // "EmptyState ... After reflection, After pausing (wait pausing saves timestamp and navigates to Empty State)."
                    
                    // The spec says:
                    // Pause -> intent.isPaused = true -> Navigates to Empty State Screen.
                    // BUT Return Screen appears if "App opens and a paused intent exists".
                    // So if we just paused, we are ON Empty State.
                    // If we close app and reopen, we see Return Screen.
                    
                    // Let's refine the logic.
                    // If currentIntent is paused:
                    //   Are we "Just Paused"? The user wants to see Empty State.
                    //   Are we "Returning"? The user wants to see Return Screen.
                    //   We can track `justPaused` in memory (not persisted).
                    
                    if hasPausedIntentButShouldShowEmpty {
                         EmptyStateView(onCapture: { isCapturing = true })
                    } else if let intent = intentManager.currentIntent, intent.status == .paused {
                         ReturnView(intent: intent)
                    } else {
                        // Truly empty (No intent object)
                        // If it's the very first launch vs empty state after reflection?
                        // Visually LaunchScreen and EmptyState are distinct in the spec.
                        // Launch: "What's on your mind?"
                        // Empty: "Nothing is anchored."
                        
                        // Let's distinguish by checking if we ever had an intent or just use a flag?
                        // Or maybe they are similar enough to reuse, but the spec separates them.
                        // "Launch Screen ... App is opened ... no active or paused intent"
                        // "Empty State ... No active or paused intent exists"
                        
                        // Wait, if "No active or paused intent exists", then `intentManager.currentIntent` is NIL.
                        // Ideally we check if we launched fresh?
                        // Let's just default to LaunchScreen if nil, or EmptyScreen if we just finished something?
                        // Actually, if we just finished reflection -> Empty.
                        // If we start fresh -> Launch.
                        
                        // Simple heuristic: 
                        // If `intentManager.currentIntent` is nil -> LaunchView.
                        // If we explicitly navigated to Empty (via Reflection finish), we are there.
                        // But Reflection finish does `clearIntent`, setting it to nil.
                        // So we immediately see LaunchView again? which says "What's on your mind?"
                        // That seems fine.
                        
                        LaunchView(onStartCapture: { isCapturing = true })
                    }
                }
            }
            .animation(.default, value: intentManager.currentIntent?.status)
            .animation(.default, value: intentManager.currentIntent == nil)
        }
    }
    
    // Logic for "Just Paused" vs "Return"
    // If we just paused, the intent status is .paused. 
    // We want to show EmptyStateView.
    // If we reload the app, we want ReturnView.
    // Implementation:
    // We can add a `@State` or check a session flag in IntentManager.
    // But wait, the Spec for Anchor Screen says:
    // "Pause for Later: Marks intent as paused ... Navigates to Empty State Screen"
    // Spec for Empty State Screen: "When This Screen Appears ... After pausing an intent"
    // Spec for Return Screen: "App opens and a paused intent exists".
    
    // So:
    // If State == Paused AND App Just Opened -> ReturnView.
    // If State == Paused AND User Just Clicked Pause -> EmptyStateView.
    
    // Use a secondary check.
    // But `ContentView` re-init on app launch? Yes.
    // So on Launch, `justPaused` is false. -> ReturnView. Correct.
    // When clicking Pause, we set `justPaused` = true (if we can signal it).
    
    var hasPausedIntentButShouldShowEmpty: Bool {
        guard let intent = intentManager.currentIntent, intent.status == .paused else { return false }
        // We need to know if we 'just' paused.
        // We can ask IntentManager.
        return intentManager.justPaused
    }
}
