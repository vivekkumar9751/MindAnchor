import Foundation

struct FocusInsights {
    var totalFocusMinutes: Int
    var currentStreak: Int
    var topEmotion: String?
    var completeSessions: Int
    var narratives: [String] // New: Text-based insights
}

@MainActor
class InsightEngine {
    static let shared = InsightEngine()
    
    private init() {}
    
    func calculateInsights(history: [Intent]) -> FocusInsights {
        let completed = history.filter { $0.status == .completed }
        
        let totalMinutes = completed.reduce(0) { sum, intent in
            // Use estimatedDuration for now, defaulting to 30 mins if nil
            let duration = (intent.estimatedDuration ?? 1800) / 60
            return sum + Int(duration)
        }
        
        let streak = calculateStreak(for: completed)
        let topEmotion = calculateTopEmotion(for: completed)
        let narratives = generateNarratives(for: completed, totalMinutes: totalMinutes, streak: streak)
        
        return FocusInsights(
            totalFocusMinutes: totalMinutes,
            currentStreak: streak,
            topEmotion: topEmotion,
            completeSessions: completed.count,
            narratives: narratives
        )
    }
    
    // MARK: - Narrative Generation
    private func generateNarratives(for intents: [Intent], totalMinutes: Int, streak: Int) -> [String] {
        var insights: [String] = []
        
        if intents.isEmpty {
            return ["Start your journey to see patterns emerge."]
        }
        
        // 1. Time of Day Pattern
        if let timePattern = calculateTimeOfDayPattern(for: intents) {
            insights.append(timePattern)
        }
        
        // 2. Consistency / Streak
        if streak >= 3 {
            insights.append("You're building a strong habit with a \(streak)-day streak! 🔥")
        } else if intents.count > 5 {
             insights.append("Consistency is key. You've anchored \(intents.count) times total.")
        }
        
        // 3. Duration Trends
        // Check last 3 vs previous 3? slightly complex.
        // Simple check: "You focused longer this week." if totalMinutes > some threshold or average increases.
        // Let's do a simple count check for now.
        let thisWeekCount = intents.filter { Calendar.current.isDateInThisWeek($0.createdAt) }.count
        if thisWeekCount > 3 {
            insights.append("You've been very active this week with \(thisWeekCount) sessions.")
        }
        
        // 4. Distraction Analysis
        let totalDistractions = intents.reduce(0) { $0 + $1.distractions.count }
        if totalDistractions == 0 && intents.count > 3 {
            insights.append("Laser Focus: You rarely get distracted based on recent sessions. 🎯")
        } else if totalDistractions > 0 {
            let avg = Double(totalDistractions) / Double(intents.count)
            if avg < 1.0 {
                 insights.append("You handle distractions well, averaging less than 1 per session.")
            }
        }
        
        return insights
    }
    
    private func calculateTimeOfDayPattern(for intents: [Intent]) -> String? {
        // Group by hour
        let calendar = Calendar.current
        var morning = 0
        var afternoon = 0
        var evening = 0
        
        for intent in intents {
            let hour = calendar.component(.hour, from: intent.createdAt)
            switch hour {
            case 5..<12: morning += 1
            case 12..<17: afternoon += 1
            case 17..<24: evening += 1 // Late night logic?
            default: break // 0-5am, maybe night owls
            }
        }
        
        let total = Double(intents.count)
        if total < 3 { return nil } // Not enough data
        
        if Double(morning) / total > 0.5 {
            return "Morning sessions seem most productive for you. ☀️"
        } else if Double(afternoon) / total > 0.5 {
            return "You find your flow mostly in the afternoons. 🌤️"
        } else if Double(evening) / total > 0.5 {
            return "Evening anchors help you wind down effectively. 🌙"
        }
        
        return nil
    }
    
    // MARK: - Existing Helpers
    
    private func calculateStreak(for intents: [Intent]) -> Int {
        // Streaks: consecutive days with at least one completed intent
        guard !intents.isEmpty else { return 0 }
        
        let sortedDates = intents.map { Calendar.current.startOfDay(for: $0.createdAt) }
            .sorted(by: >)
            .removingDuplicates()
        
        var streak = 0
        let today = Calendar.current.startOfDay(for: Date())
        
        // If the user hasn't focused today or yesterday, streak is broken (0).
        guard let lastDate = sortedDates.first else { return 0 }
        
        let daysSinceLast = Calendar.current.dateComponents([.day], from: lastDate, to: today).day ?? 0
        
        if daysSinceLast > 1 {
            return 0
        }
        
        var currentDate = lastDate
        streak = 1 // Start with the last active day
        
        for i in 1..<sortedDates.count {
            let previousDate = sortedDates[i]
            let diff = Calendar.current.dateComponents([.day], from: previousDate, to: currentDate).day ?? 0
            
            if diff == 1 {
                streak += 1
                currentDate = previousDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateTopEmotion(for intents: [Intent]) -> String? {
        var counts: [String: Int] = [:]
        
        for intent in intents {
            if let emotion = intent.completionEmotion {
                counts[emotion, default: 0] += 1
            }
        }
        
        return counts.sorted { $0.value > $1.value }.first?.key
    }
}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}

extension Calendar {
    func isDateInThisWeek(_ date: Date) -> Bool {
        return isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
}
