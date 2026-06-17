// Gestión de ventas: valida stock, calcula subtotal/IGV 18%/total y persiste en una sola transacción.
import Foundation

final class SaleService: SaleServiceProtocol {

    // MARK: - Properties

    private let saleRepository: SaleRepository
    private let productRepository: ProductRepository
    private static let igvRate = 0.18

    init(repository: SaleRepository, productRepository: ProductRepository) {
        self.saleRepository = repository
        self.productRepository = productRepository
    }

    // MARK: - SaleServiceProtocol

    func fetchAll(startDate: Date?, endDate: Date?) -> [Venta] {
        saleRepository.fetchAll(startDate: startDate, endDate: endDate).map { $0.toDomain() }
    }

    func create(clienteId: UUID, productoId: UUID, cantidad: Int) -> Result<Venta, ServiceError> {
        guard let productoEntity = productRepository.find(byId: productoId) else {
            return .failure(.notFound)
        }
        guard Int(productoEntity.stock) >= cantidad else {
            return .failure(.insufficientStock)
        }

        let precio   = productoEntity.precio
        let subtotal = precio * Double(cantidad)
        let igv      = subtotal * Self.igvRate
        let total    = subtotal + igv
        let fecha    = Date()

        let id: UUID
        do {
            id = try saleRepository.create(
                clienteId: clienteId,
                productoId: productoId,
                cantidad: Int32(cantidad),
                precio: precio,
                subtotal: subtotal,
                igv: igv,
                total: total
            )
        } catch {
            return .failure(.saveFailed)
        }

        let venta = Venta(
            id: id,
            fecha: fecha,
            cantidad: Int32(cantidad),
            precio: precio,
            subtotal: subtotal,
            igv: igv,
            total: total,
            clienteId: clienteId,
            productoId: productoId
        )
        return .success(venta)
    }

    func fetchByClient(id: UUID) -> [Venta] {
        saleRepository.fetchByClient(id: id).map { $0.toDomain() }
    }

    func fetchByProduct(id: UUID) -> [Venta] {
        saleRepository.fetchByProduct(id: id).map { $0.toDomain() }
    }

    func calculateTotals(startDate: Date?, endDate: Date?) -> SaleSummary {
        let ventas = saleRepository.fetchAll(startDate: startDate, endDate: endDate)
        return SaleSummary(
            totalVentas: ventas.count,
            montoTotal:  ventas.reduce(0) { $0 + $1.total },
            igvTotal:    ventas.reduce(0) { $0 + $1.igv }
        )
    }
}
