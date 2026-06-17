// Contrato para la gestión de clientes registrados.
import Foundation

protocol ClientServiceProtocol {
    func fetchAll(searchText: String?) -> [Cliente]
    func create(_ client: Cliente) -> Result<Cliente, ServiceError>
    func update(_ client: Cliente) -> Result<Cliente, ServiceError>
    func delete(id: UUID) -> Result<Void, ServiceError>
    func findByDNI(_ dni: String) -> Cliente?
}
