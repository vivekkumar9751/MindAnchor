import WidgetKit
import SwiftUI
import CoreData

// 1. Timeline Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let intent: Intent?
    let progress: Double
    let isFocusMode: Bool
}

// 2. Provider
struct Provider: TimelineProvider {
    // Access Core Data
    private let context = PersistenceController.shared.container.viewContext
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), intent: .mock, progress: 0.3, isFocusMode: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), intent: .mock, progress: 0.3, isFocusMode: true)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let currentDate = Date()
        
        // Fetch active intent from Core Data
        let intent = fetchCurrentIntent()
        
        // Calculate progress
        var progress: Double = 0
        var isFocusMode = false
        
        if let intent = intent, intent.status == .active {
            isFocusMode = true
            let duration = intent.estimatedDuration ?? 1800
            let elapsed = currentDate.timeIntervalSince(intent.createdAt)
            progress = max(0, min(1, elapsed / duration))
        }
        
        // Create entry
        let entry = SimpleEntry(date: currentDate, intent: intent, progress: progress, isFocusMode: isFocusMode)
        
        // Refresh every minute to update progress bar
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func fetchCurrentIntent() -> Intent? {
        let request: NSFetchRequest<IntentEntity> = NSFetchRequest(entityName: "IntentEntity")
        request.predicate = NSPredicate(format: "status != %@", IntentStatus.completed.rawValue)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                return mapToStruct(entity)
            }
        } catch {
            print("Widget Error: \(error)")
        }
        return nil
    }
    
    // Duplicate of mapToStruct logic - in a real app, share this logic
    private func mapToStruct(_ entity: IntentEntity) -> Intent {
        var distractions: [String] = []
        if let raw = entity.distractionsRaw {
            distractions = raw.components(separatedBy: "|||")
        }
        
        return Intent(
            id: entity.id,
            text: entity.text,
            why: entity.why,
            status: IntentStatus(rawValue: entity.status) ?? .active,
            createdAt: entity.createdAt,
            pausedAt: entity.pausedAt,
            emotionalContext: entity.emotionalContext,
            estimatedDuration: entity.estimatedDuration,
            distractions: distractions,
            completionEmotion: entity.completionEmotion
        )
    }
}

// 3. Widget Configuration
struct MindAnchorWidget: Widget {
    let kind: String = "MindAnchorWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if let intent = entry.intent {
                MindAnchorWidgetView(intent: intent, progress: entry.progress, isFocusMode: entry.isFocusMode)
            } else {
                // Empty State
                VStack {
                    Image(systemName: "anchor")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No Active Anchor")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .background(Color(UIColor.systemBackground))
            }
        }
        .configurationDisplayName("Current Anchor")
        .description("Track your current focus goal.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// Mock extension for preview
extension Intent {
    static let mock = Intent(id: UUID(), text: "Design Widgets", why: "To win the challenge", status: .active, createdAt: Date(), pausedAt: nil, emotionalContext: "Excited", estimatedDuration: 1800, distractions: [], completionEmotion: nil)
}
