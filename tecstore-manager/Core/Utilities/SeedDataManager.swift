// Inserta datos de ejemplo en el primer arranque; idempotente si ya existen registros.
import CoreData

final class SeedDataManager {

    // MARK: - Properties

    private let stack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.stack = coreDataStack
    }

    // MARK: - Public

    func seedIfNeeded() {
        seedProductsIfNeeded()
        seedClientsIfNeeded()
    }

    // MARK: - Products

    private func seedProductsIfNeeded() {
        let request = ProductoEntity.fetchRequest()
        guard let count = try? stack.viewContext.count(for: request), count == 0 else { return }

        let products: [(codigo: String, nombre: String, categoria: String, precio: Double, stock: Int32)] = [
            ("PROD-0001", "Laptop HP",        "Electrónica", 2500.00, 10),
            ("PROD-0002", "Mouse Logitech",   "Electrónica",   45.00, 50),
            ("PROD-0003", "Polo Nike",         "Ropa",          89.90, 30),
            ("PROD-0004", "Arroz 5kg",         "Alimentos",     18.50, 100),
            ("PROD-0005", "Teclado Mecánico",  "Electrónica",  120.00, 25)
        ]

        var saveError: Error?
        let context = stack.newBackgroundContext()
        context.performAndWait {
            for p in products {
                let entity = ProductoEntity(context: context)
                entity.id            = UUID()
                entity.codigo        = p.codigo
                entity.nombre        = p.nombre
                entity.categoria     = p.categoria
                entity.precio        = p.precio
                entity.stock         = p.stock
                entity.fechaRegistro = Date()
                entity.estado        = true
            }
            do { try context.save() } catch { saveError = error }
        }
        if let error = saveError {
            print("SeedDataManager: error al insertar productos — \(error)")
        }
    }

    // MARK: - Clients

    private func seedClientsIfNeeded() {
        let request = ClienteEntity.fetchRequest()
        guard let count = try? stack.viewContext.count(for: request), count == 0 else { return }

        let clients: [(dni: String, nombres: String, apellidos: String, telefono: String, correo: String)] = [
            ("12345678", "Juan",   "Pérez", "987654321", "juan@mail.com"),
            ("87654321", "María",  "López", "912345678", "maria@mail.com"),
            ("11223344", "Carlos", "Ruiz",  "945678123", "carlos@mail.com")
        ]

        var saveError: Error?
        let context = stack.newBackgroundContext()
        context.performAndWait {
            for c in clients {
                let entity = ClienteEntity(context: context)
                entity.id        = UUID()
                entity.dni       = c.dni
                entity.nombres   = c.nombres
                entity.apellidos = c.apellidos
                entity.telefono  = c.telefono
                entity.correo    = c.correo
                entity.estado    = true
            }
            do { try context.save() } catch { saveError = error }
        }
        if let error = saveError {
            print("SeedDataManager: error al insertar clientes — \(error)")
        }
    }
}
