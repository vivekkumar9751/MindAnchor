import Foundation
import SwiftUI

class IntentManager: ObservableObject {
    @Published var currentIntent: Intent? {
        didSet {
            save()
        }
    }
    
    // Ephemeral state to track if we just paused in this session
    @Published var justPaused: Bool = false
    
    @Published var history: [Intent] = []
    
    private let key = "saved_intent"
    private let historyKey = "intent_history"
    
    init() {
        load()
    }
    
    // MARK: - Actions
    
    func saveIntent(_ intent: Intent) {
        self.currentIntent = intent
        self.justPaused = false
    }
    
    func markDone() {
        guard var intent = currentIntent else { return }
        intent.status = .completed
        self.currentIntent = intent
        self.justPaused = false
    }
    
    func completeIntent(emotion: String?, reflection: String?) {
        guard var intent = currentIntent else { return }
        intent.status = .completed
        intent.completionEmotion = emotion
        // We could add reflection text to intent if we had a field, 
        // but for now we just save the emotion.
        
        // Add to history
        history.append(intent)
        saveHistory()
        
        // Clear current
        clearIntent()
    }
    
    func pauseIntent() {
        guard var intent = currentIntent else { return }
        intent.status = .paused
        intent.pausedAt = Date()
        self.currentIntent = intent
        // We set this to true so UI shows Empty State instead of Return View
        self.justPaused = true
    }
    
    func resumeIntent() {
        guard var intent = currentIntent else { return }
        intent.status = .active
        intent.pausedAt = nil
        self.currentIntent = intent
        self.justPaused = false
    }
    
    func clearIntent() {
        self.currentIntent = nil
        UserDefaults.standard.removeObject(forKey: key)
        self.justPaused = false
    }
    
    // MARK: - Extended Actions
    
    func logDistraction(_ text: String) {
        guard var intent = currentIntent else { return }
        intent.distractions.append(text)
        self.currentIntent = intent
        self.justPaused = false // Logging a distraction returns you to Anchor, not Pause
    }
    
    func updateIntentDetails(emotionalContext: String?, duration: TimeInterval?) {
        guard var intent = currentIntent else { return }
        intent.emotionalContext = emotionalContext
        intent.estimatedDuration = duration
        self.currentIntent = intent
    }

    // MARK: - Persistence
    
    private func save() {
        if let intent = currentIntent, let data = try? JSONEncoder().encode(intent) {
            UserDefaults.standard.set(data, forKey: key)
        } else if currentIntent == nil {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    private func saveHistory() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let intent = try? JSONDecoder().decode(Intent.self, from: data) {
            // Only load if it's not completed (though completed ones shouldn't be saved as current usually)
            if intent.status != .completed {
                self.currentIntent = intent
            }
        }
    }
}
