// Conversión entre ClienteEntity (Core Data) y el modelo de dominio Cliente.
import CoreData

extension ClienteEntity {

    // MARK: - Convenience Init

    convenience init(
        context: NSManagedObjectContext,
        dni: String,
        nombres: String,
        apellidos: String,
        telefono: String? = nil,
        correo: String? = nil,
        direccion: String? = nil,
        estado: Bool = true,
        latitud: Double = 0.0,
        longitud: Double = 0.0,
        ubicacionDireccion: String? = nil
    ) {
        self.init(context: context)
        self.id                  = UUID()
        self.dni                 = dni
        self.nombres             = nombres
        self.apellidos           = apellidos
        self.telefono            = telefono
        self.correo              = correo
        self.direccion           = direccion
        self.estado              = estado
        self.latitud             = latitud
        self.longitud            = longitud
        self.ubicacionDireccion  = ubicacionDireccion
    }

    // MARK: - Domain Mapping

    func toDomain() -> Cliente {
        Cliente(
            id:                  self.id        ?? UUID(),
            dni:                 self.dni       ?? "",
            nombres:             self.nombres   ?? "",
            apellidos:           self.apellidos ?? "",
            telefono:            self.telefono,
            correo:              self.correo,
            direccion:           self.direccion,
            estado:              self.estado,
            latitud:             self.latitud == 0.0 ? nil : self.latitud,
            longitud:            self.longitud == 0.0 ? nil : self.longitud,
            ubicacionDireccion:  self.ubicacionDireccion
        )
    }
}
