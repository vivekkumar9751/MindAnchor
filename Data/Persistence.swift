import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        // Programmatically define the model to avoid .xcdatamodeld complexity
        // We define it locally here to avoid global mutable state concurrency issues
        let model = NSManagedObjectModel()
        
        // Define Entity
        let entity = NSEntityDescription()
        entity.name = "IntentEntity"
        entity.managedObjectClassName = NSStringFromClass(IntentEntity.self)
        
        // Attributes
        var properties: [NSAttributeDescription] = []
        
        let idAttr = NSAttributeDescription()
        idAttr.name = "id"
        idAttr.attributeType = .UUIDAttributeType
        idAttr.isOptional = false
        properties.append(idAttr)
        
        let textAttr = NSAttributeDescription()
        textAttr.name = "text"
        textAttr.attributeType = .stringAttributeType
        textAttr.isOptional = false
        properties.append(textAttr)
        
        // Added missing 'why' attribute
        let whyAttr = NSAttributeDescription()
        whyAttr.name = "why"
        whyAttr.attributeType = .stringAttributeType
        whyAttr.isOptional = false
        properties.append(whyAttr)
        
        let statusAttr = NSAttributeDescription()
        statusAttr.name = "status"
        statusAttr.attributeType = .stringAttributeType
        statusAttr.isOptional = false
        properties.append(statusAttr)
        
        let createdAtAttr = NSAttributeDescription()
        createdAtAttr.name = "createdAt"
        createdAtAttr.attributeType = .dateAttributeType
        createdAtAttr.isOptional = false
        properties.append(createdAtAttr)
        
        let pausedAtAttr = NSAttributeDescription()
        pausedAtAttr.name = "pausedAt"
        pausedAtAttr.attributeType = .dateAttributeType
        pausedAtAttr.isOptional = true
        properties.append(pausedAtAttr)
        
        let emotionalContextAttr = NSAttributeDescription()
        emotionalContextAttr.name = "emotionalContext"
        emotionalContextAttr.attributeType = .stringAttributeType
        emotionalContextAttr.isOptional = true
        properties.append(emotionalContextAttr)
        
        let durationAttr = NSAttributeDescription()
        durationAttr.name = "estimatedDuration"
        durationAttr.attributeType = .doubleAttributeType
        durationAttr.isOptional = true
        properties.append(durationAttr)
        
        let completionEmotionAttr = NSAttributeDescription()
        completionEmotionAttr.name = "completionEmotion"
        completionEmotionAttr.attributeType = .stringAttributeType
        completionEmotionAttr.isOptional = true
        properties.append(completionEmotionAttr)
        
        // Transformable for String array "distractions"
        let distractionsAttr = NSAttributeDescription()
        distractionsAttr.name = "distractionsRaw"
        distractionsAttr.attributeType = .stringAttributeType
        distractionsAttr.isOptional = true
        properties.append(distractionsAttr)
        
        entity.properties = properties
        model.entities = [entity]
        
        // Use the programmatic model
        container = NSPersistentContainer(name: "MindAnchor", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

// Map the entity class manually since we aren't using codegen
@objc(IntentEntity)
public class IntentEntity: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var text: String
    @NSManaged public var why: String
    @NSManaged public var status: String
    @NSManaged public var createdAt: Date
    @NSManaged public var pausedAt: Date?
    @NSManaged public var emotionalContext: String?
    @NSManaged public var estimatedDuration: Double
    @NSManaged public var completionEmotion: String?
    @NSManaged public var distractionsRaw: String?
}
