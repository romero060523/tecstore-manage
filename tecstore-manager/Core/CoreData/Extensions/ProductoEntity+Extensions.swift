// Conversión entre ProductoEntity (Core Data) y el modelo de dominio Producto.
import CoreData

extension ProductoEntity {

    // MARK: - Convenience Init

    convenience init(
        context: NSManagedObjectContext,
        codigo: String,
        nombre: String,
        categoria: String,
        precio: Double,
        stock: Int32,
        fechaRegistro: Date = Date(),
        estado: Bool = true,
        imagenData: Data? = nil
    ) {
        self.init(context: context)
        self.id            = UUID()
        self.codigo        = codigo
        self.nombre        = nombre
        self.categoria     = categoria
        self.precio        = precio
        self.stock         = stock
        self.fechaRegistro = fechaRegistro
        self.estado        = estado
        self.imagenData    = imagenData
    }

    // MARK: - Domain Mapping

    func toDomain() -> Producto {
        Producto(
            id:            self.id            ?? UUID(),
            codigo:        self.codigo        ?? "",
            nombre:        self.nombre        ?? "",
            categoria:     self.categoria     ?? "",
            precio:        self.precio,
            stock:         self.stock,
            fechaRegistro: self.fechaRegistro ?? Date(),
            estado:        self.estado,
            imagenData:    self.imagenData
        )
    }
}
