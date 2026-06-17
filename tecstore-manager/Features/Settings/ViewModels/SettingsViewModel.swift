import Foundation
import Combine

final class SettingsViewModel: ObservableObject {

    // MARK: - Published State

    @Published var currentUser: String = UserDefaults.standard.string(forKey: "currentUserName") ?? "Admin"
    @Published var totalProductos: Int = 0
    @Published var totalClientes: Int = 0
    @Published var totalVentas: Int = 0

    // MARK: - Navigation Closures

    var onLogout: (() -> Void)?
    var onNavigateToReports: (() -> Void)?
    var onNavigateToAbout: (() -> Void)?

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
        loadStats()
    }

    // MARK: - Actions

    func loadStats() {
        totalProductos = productService.fetchAll(searchText: nil, category: nil).count
        totalClientes  = clientService.fetchAll(searchText: nil).count
        totalVentas    = saleService.fetchAll(startDate: nil, endDate: nil).count
    }

    func logout() {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "currentUserId")
        onLogout?()
    }
}
