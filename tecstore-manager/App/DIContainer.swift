// Contenedor de dependencias: instancia y provee todos los servicios de la aplicación.
import Foundation

final class DIContainer {

    // MARK: - Core

    let coreDataStack: CoreDataStack

    // MARK: - Services

    lazy var authService: AuthServiceProtocol = AuthService(
        repository: UserRepository(coreDataStack: coreDataStack)
    )

    lazy var productService: ProductServiceProtocol = ProductService(
        repository: ProductRepository(coreDataStack: coreDataStack),
        validationService: validationService
    )

    lazy var clientService: ClientServiceProtocol = ClientService(
        repository: ClientRepository(coreDataStack: coreDataStack),
        validationService: validationService
    )

    lazy var saleService: SaleServiceProtocol = SaleService(
        repository: SaleRepository(coreDataStack: coreDataStack),
        productRepository: ProductRepository(coreDataStack: coreDataStack)
    )

    lazy var locationService: LocationServiceProtocol = LocationService(
        repository: LocationRepository(coreDataStack: coreDataStack)
    )

    lazy var validationService: ValidationServiceProtocol = ValidationService()

    // MARK: - Init

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
}
