import Foundation
import ActivityKit

// This struct defines the dynamic data that updates in the Live Activity
struct FocusActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic state data
        var remainingTime: TimeInterval
        var progress: Double
        var isFocusMode: Bool
    }
    
    // Static data (doesn't change during the activity)
    var intentText: String
    var intentWhy: String
    var targetDate: Date
}
