// Acceso a datos de UbicacionEntity: CRUD simple sin relaciones.
import CoreData

final class LocationRepository {

    // MARK: - Properties

    private let stack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.stack = coreDataStack
    }

    // MARK: - Reads

    func fetchAll() -> [UbicacionEntity] {
        let request = UbicacionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "fecha", ascending: false)]
        return (try? stack.viewContext.fetch(request)) ?? []
    }

    // MARK: - Writes

    func create(latitud: Double, longitud: Double, direccion: String? = nil) throws {
        let context = stack.viewContext
        let entity  = UbicacionEntity(context: context)
        entity.id       = UUID()
        entity.latitud  = latitud
        entity.longitud = longitud
        entity.direccion = direccion
        entity.fecha    = Date()
        try context.save()
    }
}
