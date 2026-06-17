// Acceso a VentaEntity; la creación de venta es atómica con el descuento de stock del producto.
import CoreData

final class SaleRepository {

    // MARK: - Properties

    private let stack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.stack = coreDataStack
    }

    // MARK: - Reads

    func fetchAll(startDate: Date? = nil, endDate: Date? = nil) -> [VentaEntity] {
        let request = VentaEntity.fetchRequest()
        var predicates: [NSPredicate] = []

        if let start = startDate {
            predicates.append(NSPredicate(format: "fecha >= %@", start as CVarArg))
        }
        if let end = endDate {
            predicates.append(NSPredicate(format: "fecha <= %@", end as CVarArg))
        }
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        request.sortDescriptors = [NSSortDescriptor(key: "fecha", ascending: false)]
        return (try? stack.viewContext.fetch(request)) ?? []
    }

    func fetchByClient(id: UUID) -> [VentaEntity] {
        let request = VentaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "cliente.id == %@", id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "fecha", ascending: false)]
        return (try? stack.viewContext.fetch(request)) ?? []
    }

    func fetchByProduct(id: UUID) -> [VentaEntity] {
        let request = VentaEntity.fetchRequest()
        request.predicate = NSPredicate(format: "producto.id == %@", id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "fecha", ascending: false)]
        return (try? stack.viewContext.fetch(request)) ?? []
    }

    // MARK: - Writes

    /// Persiste la venta y decrementa el stock del producto en una sola transacción.
    @discardableResult
    func create(
        clienteId: UUID,
        productoId: UUID,
        cantidad: Int32,
        precio: Double,
        subtotal: Double,
        igv: Double,
        total: Double
    ) throws -> UUID {
        let newId = UUID()
        let newFecha = Date()
        var saveError: Error?

        let context = stack.newBackgroundContext()
        context.performAndWait {
            // Fetch y actualizar stock del producto
            let productoReq = ProductoEntity.fetchRequest()
            productoReq.predicate = NSPredicate(format: "id == %@", productoId as CVarArg)
            productoReq.fetchLimit = 1
            guard let producto = (try? context.fetch(productoReq))?.first else {
                saveError = ServiceError.notFound; return
            }
            producto.stock -= cantidad

            // Fetch cliente (relación opcional)
            let clienteReq = ClienteEntity.fetchRequest()
            clienteReq.predicate = NSPredicate(format: "id == %@", clienteId as CVarArg)
            clienteReq.fetchLimit = 1
            let cliente = (try? context.fetch(clienteReq))?.first

            // Crear venta
            let venta = VentaEntity(context: context)
            venta.id = newId
            venta.fecha = newFecha
            venta.cantidad = cantidad
            venta.precio = precio
            venta.subtotal = subtotal
            venta.igv = igv
            venta.total = total
            venta.producto = producto
            venta.cliente = cliente

            do { try context.save() } catch { saveError = error }
        }

        if let error = saveError { throw error }
        return newId
    }
}
