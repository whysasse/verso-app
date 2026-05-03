import CoreData

enum CoreDataStack {
    static let shared = CoreDataStackValue()
}

class CoreDataStackValue: ObservableObject {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Verso")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data error: \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    static var preview: CoreDataStackValue = {
        let stack = CoreDataStackValue()
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        stack.persistentContainer.persistentStoreDescriptions = [description]
        stack.persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Preview Core Data error: \(error), \(error.userInfo)")
            }
        }
        return stack
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            print("Core Data save error: \(nsError), \(nsError.userInfo)")
        }
    }
}
