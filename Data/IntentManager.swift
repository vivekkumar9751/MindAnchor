import Foundation
import SwiftUI
import CoreData
import ActivityKit
import WidgetKit

@MainActor
class IntentManager: ObservableObject {
    @Published var currentIntent: Intent? {
        didSet {
            save()
            updateActivity()
        }
    }
    
    // Ephemeral state to track if we just paused in this session
    @Published var justPaused: Bool = false
    
    @Published var history: [Intent] = []
    
    // Live Activity
    private var currentActivity: Activity<FocusActivityAttributes>?
    
    // Core Data Context
    private let context = PersistenceController.shared.container.viewContext
    
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
        
        // Add to history (local state)
        history.append(intent)
        
        // Clear current (local state)
        // The `didSet` on currentIntent will trigger `save()`, which handles the Core Data update/save.
        // But we need to be careful: if we set currentIntent = nil, `save()` might delete the entity if we logic it that way, 
        // OR `save()` might just ignore nil. 
        // Actually, `save()` captures the *value* of currentIntent. 
        // If currentIntent is nil, we assume the user has no active intent.
        // But the *completed* intent must be persisted as history.
        // So we should explicitely save the completed intent to Core Data BEFORE clearing currentIntent.
        
        saveEntity(intent) // Ensure the completed state is saved
        
        self.currentIntent = nil
        self.justPaused = false
        
        // Reload history from Core Data to be sure
        loadHistory()
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
        // This is usually called for "Cancel" or "Delete"
        if let intent = currentIntent {
            deleteEntity(intent)
        }
        self.currentIntent = nil
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

    // MARK: - Live Activity Management
    
    private func updateActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        if let intent = currentIntent, intent.status == .active {
            // Active intent: Start or Update
            if currentActivity == nil {
                startActivity(intent: intent)
            } else {
                updateRunningActivity(intent: intent)
            }
        } else {
            // No active intent (paused or completed): End
            endActivity()
        }
    }
    
    private func startActivity(intent: Intent) {
        let duration = intent.estimatedDuration ?? 1800
        let targetDate = intent.createdAt.addingTimeInterval(duration)
        
        let attributes = FocusActivityAttributes(
            intentText: intent.text,
            intentWhy: intent.why,
            targetDate: targetDate
        )
        
        let contentState = FocusActivityAttributes.ContentState(
            remainingTime: duration,
            progress: 0.0,
            isFocusMode: true
        )
        
        let content = ActivityContent(state: contentState, staleDate: nil)
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
        } catch {
            print("Error starting Live Activity: \(error)")
        }
    }
    
    private func updateRunningActivity(intent: Intent) {
        Task {
            guard let activity = currentActivity else { return }
            
            let duration = intent.estimatedDuration ?? 1800
            let elapsed = Date().timeIntervalSince(intent.createdAt)
            let progress = max(0, min(1, elapsed / duration))
            
            let updatedState = FocusActivityAttributes.ContentState(
                remainingTime: max(0, duration - elapsed),
                progress: progress,
                isFocusMode: true // We could bind this to actual Focus Mode state if we had it
            )
            
            let content = ActivityContent(state: updatedState, staleDate: nil)
            await activity.update(content)
        }
    }
    
    private func endActivity() {
        Task {
            guard let activity = currentActivity else { return }
            
            // Final state check
            let finalState = FocusActivityAttributes.ContentState(
                remainingTime: 0,
                progress: 1.0,
                isFocusMode: false
            )
             let content = ActivityContent(state: finalState, staleDate: nil)
            
            await activity.end(content, dismissalPolicy: .immediate)
            self.currentActivity = nil
        }
    }
    
    // MARK: - Persistence
    
    private func save() {
        guard let intent = currentIntent else { return }
        saveEntity(intent)
    }
    
    private func saveEntity(_ intent: Intent) {
        let request: NSFetchRequest<IntentEntity> = NSFetchRequest(entityName: "IntentEntity")
        request.predicate = NSPredicate(format: "id == %@", intent.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            let entity: IntentEntity
            
            if let existing = results.first {
                entity = existing
            } else {
                entity = IntentEntity(context: context)
                entity.id = intent.id
                entity.createdAt = intent.createdAt
            }
            
            // Update properties
            entity.text = intent.text
            entity.why = intent.why
            entity.status = intent.status.rawValue
            entity.pausedAt = intent.pausedAt
            entity.emotionalContext = intent.emotionalContext
            entity.estimatedDuration = intent.estimatedDuration ?? 0
            entity.completionEmotion = intent.completionEmotion
            
            // Serialize distractions
            if !intent.distractions.isEmpty {
                 entity.distractionsRaw = intent.distractions.joined(separator: "|||")
            } else {
                 entity.distractionsRaw = nil
            }
            
            try context.save()
            
            // Reload widget timeline
            WidgetCenter.shared.reloadAllTimelines()
            
        } catch {
            print("Error saving intent: \(error)")
        }
    }
    
    private func deleteEntity(_ intent: Intent) {
        let request: NSFetchRequest<IntentEntity> = NSFetchRequest(entityName: "IntentEntity")
        request.predicate = NSPredicate(format: "id == %@", intent.id as CVarArg)
        
        do {
            let results = try context.fetch(request)
            if let existing = results.first {
                context.delete(existing)
                try context.save()
                
                // Reload widget timeline
                WidgetCenter.shared.reloadAllTimelines()
            }
        } catch {
            print("Error deleting intent: \(error)")
        }
    }
    
    private func load() {
        // Load active or paused intent
        let request: NSFetchRequest<IntentEntity> = NSFetchRequest(entityName: "IntentEntity")
        request.predicate = NSPredicate(format: "status != %@", IntentStatus.completed.rawValue)
        
        do {
            let results = try context.fetch(request)
            if let entity = results.first {
                self.currentIntent = mapToStruct(entity)
            }
        } catch {
            print("Error loading current intent: \(error)")
        }
        
        loadHistory()
    }
    
    private func loadHistory() {
        let request: NSFetchRequest<IntentEntity> = NSFetchRequest(entityName: "IntentEntity")
        request.predicate = NSPredicate(format: "status == %@", IntentStatus.completed.rawValue)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        do {
            let results = try context.fetch(request)
            self.history = results.map { mapToStruct($0) }
        } catch {
            print("Error loading history: \(error)")
        }
    }
    
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
