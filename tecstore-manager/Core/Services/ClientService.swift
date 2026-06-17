// Gestión de clientes con validación de DNI obligatorio y correo electrónico opcional.
import Foundation

final class ClientService: ClientServiceProtocol {

    // MARK: - Properties

    private let repository: ClientRepository
    private let validation: ValidationServiceProtocol

    init(repository: ClientRepository, validationService: ValidationServiceProtocol) {
        self.repository = repository
        self.validation = validationService
    }

    // MARK: - ClientServiceProtocol

    func fetchAll(searchText: String?) -> [Cliente] {
        repository.fetchAll(searchText: searchText).map { $0.toDomain() }
    }

    func create(_ client: Cliente) -> Result<Cliente, ServiceError> {
        if let error = validate(client) { return .failure(error) }
        do {
            try repository.create(
                dni: client.dni,
                nombres: client.nombres,
                apellidos: client.apellidos,
                telefono: client.telefono,
                correo: client.correo,
                direccion: client.direccion,
                latitud: client.latitud ?? 0.0,
                longitud: client.longitud ?? 0.0,
                ubicacionDireccion: client.ubicacionDireccion
            )
            return .success(client)
        } catch {
            return .failure(.saveFailed)
        }
    }

    func update(_ client: Cliente) -> Result<Cliente, ServiceError> {
        if let error = validate(client) { return .failure(error) }
        do {
            try repository.update(
                id: client.id,
                dni: client.dni,
                nombres: client.nombres,
                apellidos: client.apellidos,
                telefono: client.telefono,
                correo: client.correo,
                direccion: client.direccion,
                estado: client.estado,
                latitud: client.latitud ?? 0.0,
                longitud: client.longitud ?? 0.0,
                ubicacionDireccion: client.ubicacionDireccion
            )
            return .success(client)
        } catch let serviceError as ServiceError {
            return .failure(serviceError)
        } catch {
            return .failure(.saveFailed)
        }
    }

    func delete(id: UUID) -> Result<Void, ServiceError> {
        do {
            try repository.delete(id: id)
            return .success(())
        } catch let serviceError as ServiceError {
            return .failure(serviceError)
        } catch {
            return .failure(.deleteFailed)
        }
    }

    func findByDNI(_ dni: String) -> Cliente? {
        repository.find(byDNI: dni)?.toDomain()
    }

    // MARK: - Private

    private func validate(_ client: Cliente) -> ServiceError? {
        var checks: [ValidationResult] = [
            validation.validateDNI(client.dni),
            validation.validateRequired(client.nombres,   fieldName: "Nombres"),
            validation.validateRequired(client.apellidos, fieldName: "Apellidos")
        ]
        if let correo = client.correo, !correo.isEmpty {
            checks.append(validation.validateEmail(correo))
        }
        if let message = checks.first(where: { !$0.isValid })?.errorMessage {
            return .validationError(message)
        }
        return nil
    }
}
