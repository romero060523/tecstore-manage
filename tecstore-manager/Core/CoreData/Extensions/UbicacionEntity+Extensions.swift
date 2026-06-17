// Conversión entre UbicacionEntity (Core Data) y el modelo de dominio Ubicacion.
import CoreData

extension UbicacionEntity {

    // MARK: - Convenience Init

    convenience init(
        context: NSManagedObjectContext,
        latitud: Double,
        longitud: Double,
        direccion: String? = nil,
        fecha: Date = Date()
    ) {
        self.init(context: context)
        self.id        = UUID()
        self.latitud   = latitud
        self.longitud  = longitud
        self.direccion = direccion
        self.fecha     = fecha
    }

    // MARK: - Domain Mapping

    func toDomain() -> Ubicacion {
        Ubicacion(
            id:        self.id    ?? UUID(),
            latitud:   self.latitud,
            longitud:  self.longitud,
            direccion: self.direccion,
            fecha:     self.fecha ?? Date()
        )
    }
}
