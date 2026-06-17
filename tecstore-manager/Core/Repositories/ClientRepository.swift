// Acceso a datos de ClienteEntity: reads en viewContext, writes en background context.
import CoreData

final class ClientRepository {

    // MARK: - Properties

    private let stack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.stack = coreDataStack
    }

    // MARK: - Reads

    func fetchAll(searchText: String? = nil) -> [ClienteEntity] {
        let request = ClienteEntity.fetchRequest()
        if let text = searchText, !text.isEmpty {
            request.predicate = NSPredicate(
                format: "nombres CONTAINS[cd] %@ OR apellidos CONTAINS[cd] %@ OR dni CONTAINS[cd] %@",
                text, text, text
            )
        }
        request.sortDescriptors = [NSSortDescriptor(key: "apellidos", ascending: true)]
        return (try? stack.viewContext.fetch(request)) ?? []
    }

    func find(byDNI dni: String) -> ClienteEntity? {
        let request = ClienteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "dni == %@", dni)
        request.fetchLimit = 1
        return (try? stack.viewContext.fetch(request))?.first
    }

    func find(byId id: UUID) -> ClienteEntity? {
        let request = ClienteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return (try? stack.viewContext.fetch(request))?.first
    }

    // MARK: - Writes

    func create(dni: String, nombres: String, apellidos: String,
                telefono: String?, correo: String?, direccion: String?) throws {
        var saveError: Error?
        let context = stack.newBackgroundContext()
        context.performAndWait {
            let entity = ClienteEntity(context: context)
            entity.id = UUID()
            entity.dni = dni
            entity.nombres = nombres
            entity.apellidos = apellidos
            entity.telefono = telefono
            entity.correo = correo
            entity.direccion = direccion
            entity.estado = true
            do { try context.save() } catch { saveError = error }
        }
        if let error = saveError { throw error }
    }

    func update(id: UUID, dni: String, nombres: String, apellidos: String,
                telefono: String?, correo: String?, direccion: String?, estado: Bool) throws {
        var saveError: Error?
        let context = stack.newBackgroundContext()
        context.performAndWait {
            let request = ClienteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            guard let entity = (try? context.fetch(request))?.first else {
                saveError = ServiceError.notFound; return
            }
            entity.dni = dni
            entity.nombres = nombres
            entity.apellidos = apellidos
            entity.telefono = telefono
            entity.correo = correo
            entity.direccion = direccion
            entity.estado = estado
            do { try context.save() } catch { saveError = error }
        }
        if let error = saveError { throw error }
    }

    func delete(id: UUID) throws {
        var saveError: Error?
        let context = stack.newBackgroundContext()
        context.performAndWait {
            let request = ClienteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            guard let entity = (try? context.fetch(request))?.first else {
                saveError = ServiceError.notFound; return
            }
            context.delete(entity)
            do { try context.save() } catch { saveError = error }
        }
        if let error = saveError { throw error }
    }
}
