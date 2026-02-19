import Foundation
import SwiftUI

// MARK: - Philosophy Enum

enum AnchorPhilosophy: String, CaseIterable, Identifiable {
    case deepWork      = "Deep Work"
    case calmClarity   = "Calm & Clarity"
    case creativeFlow  = "Creative Flow"
    case discipline    = "Discipline"
    case undecided     = "I'll decide later"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .deepWork:       return "bolt.fill"
        case .calmClarity:    return "leaf.fill"
        case .creativeFlow:   return "paintpalette.fill"
        case .discipline:     return "shield.fill"
        case .undecided:      return "questionmark.circle.fill"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .deepWork:       return .blue
        case .calmClarity:    return .green
        case .creativeFlow:   return .purple
        case .discipline:     return .orange
        case .undecided:      return .gray
        }
    }
    
    var subtitle: String {
        switch self {
        case .deepWork:
            return "Long, uninterrupted blocks of intense focus."
        case .calmClarity:
            return "Gentle, present-moment awareness and ease."
        case .creativeFlow:
            return "Open-ended exploration and expressive work."
        case .discipline:
            return "Steady commitment. You keep your word — always."
        case .undecided:
            return "No pressure — you can set this anytime in Settings."
        }
    }
    
    // MARK: - Completion Microcopy
    var completionMessage: String {
        switch self {
        case .deepWork:       return "You stayed committed."
        case .calmClarity:    return "You honored your attention."
        case .creativeFlow:   return "You followed your inspiration."
        case .discipline:     return "You kept your promise."
        case .undecided:      return "You protected your focus today."
        }
    }
    
    // MARK: - Behavioral Defaults
    var defaultDurationSeconds: TimeInterval {
        switch self {
        case .deepWork:       return 5400  // 90 min
        case .calmClarity:    return 1800  // 30 min
        case .creativeFlow:   return 2700  // 45 min (open-ended feel)
        case .discipline:     return 3600  // 60 min
        case .undecided:      return 1800  // 30 min
        }
    }
    
    var breathingOverlayByDefault: Bool {
        switch self {
        case .calmClarity:  return true
        default:            return false
        }
    }
    
    var narrativeTone: String {
        switch self {
        case .deepWork:
            return "You went deep today—solid and deliberate."
        case .calmClarity:
            return "You moved through today with quiet intention."
        case .creativeFlow:
            return "You let yourself wander into something worthwhile."
        case .discipline:
            return "You showed discipline. Steady wins the race."
        case .undecided:
            return "You showed up. That counts for a lot."
        }
    }
    
    // MARK: - Visualization Style
    var visualizationStyle: PhilosophyVisualizationStyle {
        switch self {
        case .deepWork:     return .expandingCircle
        case .calmClarity:  return .breathingWaves
        case .creativeFlow: return .floatingParticles
        case .discipline:   return .growingLine
        case .undecided:    return .expandingCircle
        }
    }
}

enum PhilosophyVisualizationStyle {
    case expandingCircle
    case breathingWaves
    case floatingParticles
    case growingLine
}
