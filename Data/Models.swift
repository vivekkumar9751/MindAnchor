import Foundation

enum IntentStatus: String, Codable {
    case active
    case paused
    case completed
}

struct Intent: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var text: String
    var why: String
    var nextStep: String?
    var status: IntentStatus
    var createdAt: Date = Date()
    var pausedAt: Date?
    
    // Helper to check if it's currently relevant (not completed)
    var isRelevant: Bool {
        return status == .active || status == .paused
    }
    
    // Phase 1: Core & Emotional Depth
    var emotionalContext: String? // "Why this matters to you?"
    var estimatedDuration: TimeInterval? // In seconds
    var distractions: [String] = [] // List of captured distractions
    var completionEmotion: String? // How did you feel when done?
    var focusModeEnabled: Bool = false // Did they ask for system focus?
}
