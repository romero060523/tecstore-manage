// Contrato para la gestión del catálogo de productos.
import Foundation

protocol ProductServiceProtocol {
    func fetchAll(searchText: String?, category: String?) -> [Producto]
    func create(_ product: Producto) -> Result<Producto, ServiceError>
    func update(_ product: Producto) -> Result<Producto, ServiceError>
    func delete(id: UUID) -> Result<Void, ServiceError>
    func findByCodigo(_ codigo: String) -> Producto?
}
