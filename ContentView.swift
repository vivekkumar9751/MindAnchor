import SwiftUI

struct ContentView: View {
    @EnvironmentObject var intentManager: IntentManager
    @State private var navigationPath = NavigationPath()
    @State private var isCapturing = false
    
    @Namespace private var namespace
    
    // We treat the "Capture Flow" as a modal or navigation push on top of a base view?
    // Or we switch the whole view hierarchy?
    // User Flow:
    // Launch -> Capture -> Snapshot -> Anchor
    // Anchor -> Done -> Reflection -> Empty
    // Empty -> Capture -> ...
    
    // BUT: Launch, Return, Anchor, Reflection, Empty are all "Root" states.
    // The "Transition" is the only time we might use navigation pushes (Capture -> Snapshot).
    
    var body: some View {
        ZStack {
            // Global Ambient Background
            FluidGradientView()
                .ignoresSafeArea()
            
            // If we represent the Capture Flow as a separate mode
            if isCapturing {
                NavigationStack(path: $navigationPath) {
                    IntentCaptureView(navigationPath: $navigationPath, namespace: namespace)
                        .navigationTitle("New Anchor")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    withAnimation(.spring()) {
                                        isCapturing = false
                                    }
                                }
                            }
                        }
                        .navigationDestination(for: DraftIntent.self) { draft in
                            ContextSnapshotView(draft: draft)
                        }
                }
                .scrollContentBackground(.hidden) // Ensure stack background is transparent
                .onChange(of: intentManager.currentIntent) { newValue in
                    if newValue != nil {
                        // Intent was saved! Exit capture mode.
                        withAnimation {
                            isCapturing = false
                        }
                    }
                }
            } else {
                // Main State Switcher
                NavigationStack {
                    Group {
                        if let intent = intentManager.currentIntent {
                            switch intent.status {
                            case .active:
                                AnchorView(intent: intent)
                            case .paused:
                                if hasPausedIntentButShouldShowEmpty {
                                     EmptyStateView(onCapture: { 
                                         withAnimation(.spring()) { isCapturing = true }
                                     })
                                } else {
                                     ReturnView(intent: intent)
                                }
                            case .completed:
                                ReflectionView()
                            }
                        } else {
                            // Truly empty (No intent object)
                            LaunchView(onStartCapture: { 
                                withAnimation(.spring()) { isCapturing = true }
                            }, namespace: namespace)
                        }
                    }
                }
                .scrollContentBackground(.hidden) // Transparency for NavigationStack
                .animation(.default, value: intentManager.currentIntent?.status)
                .animation(.default, value: intentManager.currentIntent == nil)
            }
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
