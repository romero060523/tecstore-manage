import Foundation
import Combine

final class SaleListViewModel: ObservableObject {

    // MARK: - Published State

    @Published var sales: [Venta] = []
    @Published var startDate: Date? = nil
    @Published var endDate: Date? = nil
    @Published var isLoading: Bool = false
    @Published var showDateFilter: Bool = false
    @Published var totalVentas: Int = 0
    @Published var montoTotal: Double = 0.0

    // MARK: - Private

    private let saleService: SaleServiceProtocol
    private let productService: ProductServiceProtocol
    private let clientService: ClientServiceProtocol
    private var productNames: [UUID: String] = [:]
    private var clientNames: [UUID: String] = [:]
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        saleService: SaleServiceProtocol,
        productService: ProductServiceProtocol,
        clientService: ClientServiceProtocol
    ) {
        self.saleService     = saleService
        self.productService  = productService
        self.clientService   = clientService

        productService.fetchAll(searchText: nil, category: nil).forEach {
            productNames[$0.id] = $0.nombre
        }
        clientService.fetchAll(searchText: nil).forEach {
            clientNames[$0.id] = "\($0.nombres) \($0.apellidos)"
        }

        $startDate.combineLatest($endDate)
            .dropFirst()
            .sink { [weak self] _, _ in self?.loadSales() }
            .store(in: &cancellables)

        loadSales()
    }

    // MARK: - Actions

    func loadSales() {
        isLoading = true
        sales = saleService.fetchAll(startDate: startDate, endDate: endDate)
        totalVentas = sales.count
        montoTotal  = sales.reduce(0) { $0 + $1.total }
        isLoading   = false
    }

    // MARK: - Lookups

    func getProductName(id: UUID?) -> String {
        guard let id else { return "Sin producto" }
        return productNames[id] ?? "Producto eliminado"
    }

    func getClientName(id: UUID?) -> String {
        guard let id else { return "Sin cliente" }
        return clientNames[id] ?? "Cliente eliminado"
    }
}
