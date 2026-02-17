import SwiftUI

@main
struct MyApp: App {
    @StateObject private var intentManager = IntentManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(intentManager)
        }
    }
}
