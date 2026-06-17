// Contrato para la gestión de ventas y generación de resúmenes financieros.
import Foundation

protocol SaleServiceProtocol {
    func fetchAll(startDate: Date?, endDate: Date?) -> [Venta]
    func create(clienteId: UUID, productoId: UUID, cantidad: Int) -> Result<Venta, ServiceError>
    func fetchByClient(id: UUID) -> [Venta]
    func fetchByProduct(id: UUID) -> [Venta]
    func calculateTotals(startDate: Date?, endDate: Date?) -> SaleSummary
}

// MARK: - SaleSummary

/// Resumen agregado de ventas para un período determinado.
struct SaleSummary {
    let totalVentas: Int
    let montoTotal: Double
    let igvTotal: Double
}
