import AppIntents
import SwiftUI

// This AppIntent allows the user to start a Focus Session via Shortcuts or Siri.
// "Hey Siri, Start Focus in MindAnchor"
struct StartFocusIntent: AppIntent {
    static var title: LocalizedStringResource { "Start Focus Session" }
    static var description: IntentDescription { IntentDescription("Starts a new focus session with your default anchor.") }
    static var openAppWhenRun: Bool { true }
    
    @Parameter(title: "Intent Text")
    var text: String?
    
    @MainActor
    func perform() async throws -> some IntentResult {
        // In a real app we'd access the IntentManager dependency.
        // For Swift Playgrounds, we can rely on opening the app which triggers state restoral,
        // or effectively "donating" this intent.
        // Deep linking would be better here.
        return .result(opensIntent: OpenURLIntent(URL(string: "mindanchor://start?text=\(text ?? "Focus")")!))
    }
}

struct OpenURLIntent: AppIntent {
    static var title: LocalizedStringResource { "Open URL" }
    @Parameter(title: "URL")
    var url: URL
    
    init() {}
    init(_ url: URL) { self.url = url }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        await UIApplication.shared.open(url)
        return .result()
    }
}

// Shortcuts Provider
struct MindAnchorShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartFocusIntent(),
            phrases: [
                "Start Focus in \(.applicationName)",
                "Start \(.applicationName) Focus"
            ],
            shortTitle: "Start Focus",
            systemImageName: "brain.head.profile"
        )
    }
}
