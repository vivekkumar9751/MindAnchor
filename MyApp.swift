import SwiftUI

@main
struct MyApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var intentManager = IntentManager()
    @StateObject private var soundManager = SoundManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(intentManager)
                .environmentObject(soundManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "mindanchor", url.host == "start" else { return }
        
        // Parse query items
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let text = components?.queryItems?.first(where: { $0.name == "text" })?.value ?? "Focus"
        
        // Create new intent
        // Check if we already have one
        if intentManager.currentIntent == nil {
            let newIntent = Intent(
                id: UUID(),
                text: text,
                why: "Started via Shortcut",
                status: .active,
                createdAt: Date(),
                pausedAt: nil,
                emotionalContext: "Determined",
                estimatedDuration: 1800, // Default 30 min
                distractions: [],
                completionEmotion: nil
            )
            intentManager.saveIntent(newIntent)
        }
    }
}
