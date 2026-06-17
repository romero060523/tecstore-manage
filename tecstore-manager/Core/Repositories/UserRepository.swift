// Acceso a datos de UsuarioEntity: reads en viewContext, writes en background context.
import CoreData

final class UserRepository {

    // MARK: - Properties

    private let stack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.stack = coreDataStack
    }

    // MARK: - Reads

    func fetchAll() -> [UsuarioEntity] {
        let request = UsuarioEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]
        return (try? stack.viewContext.fetch(request)) ?? []
    }

    func find(byUsername username: String) -> UsuarioEntity? {
        let request = UsuarioEntity.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", username)
        request.fetchLimit = 1
        return (try? stack.viewContext.fetch(request))?.first
    }

    func find(byId id: UUID) -> UsuarioEntity? {
        let request = UsuarioEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return (try? stack.viewContext.fetch(request))?.first
    }

    // MARK: - Writes

    func create(username: String, password: String, fullName: String, estado: Bool = true) throws {
        var saveError: Error?
        let context = stack.newBackgroundContext()
        context.performAndWait {
            let entity = UsuarioEntity(context: context)
            entity.id = UUID()
            entity.username = username
            entity.password = password
            entity.fullName = fullName
            entity.estado = estado
            do { try context.save() } catch { saveError = error }
        }
        if let error = saveError { throw error }
    }

    func delete(id: UUID) throws {
        var saveError: Error?
        let context = stack.newBackgroundContext()
        context.performAndWait {
            let request = UsuarioEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            guard let entity = (try? context.fetch(request))?.first else { return }
            context.delete(entity)
            do { try context.save() } catch { saveError = error }
        }
        if let error = saveError { throw error }
    }
}
