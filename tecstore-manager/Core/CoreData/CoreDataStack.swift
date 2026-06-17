// Gestiona el stack de Core Data: contenedor persistente, contexto principal y guardado.
import CoreData

final class CoreDataStack {

    // MARK: - Container

    private let container: NSPersistentContainer

    // MARK: - Context

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    // MARK: - Init

    init() {
        container = NSPersistentContainer(name: "TecStoreManager")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Core Data failed to load stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Save

    func saveContext() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Core Data unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    // MARK: - Background Context

    func newBackgroundContext() -> NSManagedObjectContext {
        container.newBackgroundContext()
    }
}
