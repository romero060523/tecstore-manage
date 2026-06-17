// Acceso a datos de ProductoEntity: reads en viewContext, writes en background context.
import CoreData

final class ProductRepository {

    // MARK: - Properties

    private let stack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.stack = coreDataStack
    }

    // MARK: - Reads

    func fetchAll(searchText: String? = nil, category: String? = nil) -> [ProductoEntity] {
        let request = ProductoEntity.fetchRequest()
        var predicates: [NSPredicate] = []

        if let text = searchText, !text.isEmpty {
            predicates.append(NSPredicate(
                format: "nombre CONTAINS[cd] %@ OR codigo CONTAINS[cd] %@", text, text
            ))
        }
        if let cat = category, !cat.isEmpty {
            predicates.append(NSPredicate(format: "categoria == %@", cat))
        }
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        request.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]
        return (try? stack.viewContext.fetch(request)) ?? []
    }

    func find(byId id: UUID) -> ProductoEntity? {
        let request = ProductoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        return (try? stack.viewContext.fetch(request))?.first
    }

    func find(byCodigo codigo: String) -> ProductoEntity? {
        let request = ProductoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "codigo == %@", codigo)
        request.fetchLimit = 1
        return (try? stack.viewContext.fetch(request))?.first
    }

    // MARK: - Writes

    func create(codigo: String, nombre: String, categoria: String,
                precio: Double, stock: Int32, imagenData: Data? = nil) throws {
        var saveError: Error?
        let context = stack.newBackgroundContext()
        context.performAndWait {
            let entity = ProductoEntity(context: context)
            entity.id = UUID()
            entity.codigo = codigo
            entity.nombre = nombre
            entity.categoria = categoria
            entity.precio = precio
            entity.stock = stock
            entity.fechaRegistro = Date()
            entity.estado = true
            entity.imagenData = imagenData
            do { try context.save() } catch { saveError = error }
        }
        if let error = saveError { throw error }
    }

    func update(id: UUID, codigo: String, nombre: String, categoria: String,
                precio: Double, stock: Int32, estado: Bool, imagenData: Data? = nil) throws {
        var saveError: Error?
        let context = stack.newBackgroundContext()
        context.performAndWait {
            let request = ProductoEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            request.fetchLimit = 1
            guard let entity = (try? context.fetch(request))?.first else {
                saveError = ServiceError.notFound; return
            }
            entity.codigo = codigo
            entity.nombre = nombre
            entity.categoria = categoria
            entity.precio = precio
            entity.stock = stock
            entity.estado = estado
            entity.imagenData = imagenData
            do { try context.save() } catch { saveError = error }
        }
        if let error = saveError { throw error }
    }

    func delete(id: UUID) throws {
        var saveError: Error?
        let context = stack.newBackgroundContext()
        context.performAndWait {
            let request = ProductoEntity.fetchRequest()
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
