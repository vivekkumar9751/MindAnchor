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
        }
    }
}
