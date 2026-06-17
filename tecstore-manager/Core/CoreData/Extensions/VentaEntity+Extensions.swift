// Conversión entre VentaEntity (Core Data) y el modelo de dominio Venta.
import CoreData

extension VentaEntity {

    // MARK: - Convenience Init

    convenience init(
        context: NSManagedObjectContext,
        fecha: Date = Date(),
        cantidad: Int32,
        precio: Double,
        subtotal: Double,
        igv: Double,
        total: Double,
        cliente: ClienteEntity? = nil,
        producto: ProductoEntity? = nil
    ) {
        self.init(context: context)
        self.id       = UUID()
        self.fecha    = fecha
        self.cantidad = cantidad
        self.precio   = precio
        self.subtotal = subtotal
        self.igv      = igv
        self.total    = total
        self.cliente  = cliente
        self.producto = producto
    }

    // MARK: - Domain Mapping

    func toDomain() -> Venta {
        Venta(
            id:         self.id    ?? UUID(),
            fecha:      self.fecha ?? Date(),
            cantidad:   self.cantidad,
            precio:     self.precio,
            subtotal:   self.subtotal,
            igv:        self.igv,
            total:      self.total,
            clienteId:  self.cliente?.id,
            productoId: self.producto?.id
        )
    }
}
