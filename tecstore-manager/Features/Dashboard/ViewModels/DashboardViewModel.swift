import Foundation
import Combine

final class DashboardViewModel: ObservableObject {

    // MARK: - Published State

    @Published var totalProductos: Int = 0
    @Published var totalClientes: Int = 0
    @Published var totalVentas: Int = 0
    @Published var montoTotalVentas: Double = 0.0
    @Published var productosConBajoStock: [Producto] = []
    @Published var ventasRecientes: [Venta] = []
    @Published var ventasHoy: Int = 0
    @Published var montoHoy: Double = 0.0

    // MARK: - Private

    private let productService: ProductServiceProtocol
    private let clientService: ClientServiceProtocol
    private let saleService: SaleServiceProtocol

    // MARK: - Init

    init(
        productService: ProductServiceProtocol,
        clientService: ClientServiceProtocol,
        saleService: SaleServiceProtocol
    ) {
        self.productService = productService
        self.clientService  = clientService
        self.saleService    = saleService
        loadDashboard()
    }

    // MARK: - Actions

    func loadDashboard() {
        let allProducts = productService.fetchAll(searchText: nil, category: nil)
        totalProductos          = allProducts.count
        productosConBajoStock   = allProducts.filter { $0.stock <= 5 && $0.stock > 0 }

        totalClientes = clientService.fetchAll(searchText: nil).count

        let allSales     = saleService.fetchAll(startDate: nil, endDate: nil)
        totalVentas      = allSales.count
        montoTotalVentas = allSales.reduce(0) { $0 + $1.total }
        ventasRecientes  = Array(allSales.prefix(5))

        let startOfDay   = Calendar.current.startOfDay(for: Date())
        let hoy          = allSales.filter { $0.fecha >= startOfDay }
        ventasHoy        = hoy.count
        montoHoy         = hoy.reduce(0) { $0 + $1.total }
    }
}
