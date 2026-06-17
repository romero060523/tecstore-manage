// Gestión del catálogo de productos con validación previa a cada persistencia.
import Foundation

final class ProductService: ProductServiceProtocol {

    // MARK: - Properties

    private let repository: ProductRepository
    private let validation: ValidationServiceProtocol

    init(repository: ProductRepository, validationService: ValidationServiceProtocol) {
        self.repository = repository
        self.validation = validationService
    }

    // MARK: - ProductServiceProtocol

    func fetchAll(searchText: String?, category: String?) -> [Producto] {
        repository.fetchAll(searchText: searchText, category: category).map { $0.toDomain() }
    }

    func create(_ product: Producto) -> Result<Producto, ServiceError> {
        if let error = validate(product) { return .failure(error) }
        do {
            try repository.create(
                codigo: product.codigo,
                nombre: product.nombre,
                categoria: product.categoria,
                precio: product.precio,
                stock: product.stock
            )
            return .success(product)
        } catch {
            return .failure(.saveFailed)
        }
    }

    func update(_ product: Producto) -> Result<Producto, ServiceError> {
        if let error = validate(product) { return .failure(error) }
        do {
            try repository.update(
                id: product.id,
                codigo: product.codigo,
                nombre: product.nombre,
                categoria: product.categoria,
                precio: product.precio,
                stock: product.stock,
                estado: product.estado
            )
            return .success(product)
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

    func findByCodigo(_ codigo: String) -> Producto? {
        repository.find(byCodigo: codigo)?.toDomain()
    }

    // MARK: - Private

    private func validate(_ product: Producto) -> ServiceError? {
        let checks: [ValidationResult] = [
            validation.validateRequired(product.codigo,    fieldName: "Código"),
            validation.validateRequired(product.nombre,    fieldName: "Nombre"),
            validation.validateRequired(product.categoria, fieldName: "Categoría"),
            validation.validatePrice(product.precio),
            validation.validateStock(Int(product.stock))
        ]
        if let message = checks.first(where: { !$0.isValid })?.errorMessage {
            return .validationError(message)
        }
        return nil
    }
}
