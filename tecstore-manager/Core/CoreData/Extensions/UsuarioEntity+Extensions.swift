// Conversión entre UsuarioEntity (Core Data) y el modelo de dominio Usuario.
import CoreData

extension UsuarioEntity {

    // MARK: - Convenience Init

    convenience init(
        context: NSManagedObjectContext,
        username: String,
        password: String,
        fullName: String,
        estado: Bool = true
    ) {
        self.init(context: context)
        self.id       = UUID()
        self.username = username
        self.password = password
        self.fullName = fullName
        self.estado   = estado
    }

    // MARK: - Domain Mapping

    func toDomain() -> Usuario {
        Usuario(
            id:       self.id       ?? UUID(),
            username: self.username ?? "",
            password: self.password ?? "",
            fullName: self.fullName ?? "",
            estado:   self.estado
        )
    }
}
