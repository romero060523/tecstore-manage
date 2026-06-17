// Coordinador principal: gestiona el UITabBarController con las 6 secciones de la app.
import SwiftUI
import UIKit

final class MainCoordinator: Coordinator {

    // MARK: - Coordinator

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    // MARK: - Properties

    var onLogout: (() -> Void)?
    private let container: DIContainer
    private(set) var tabBarController = UITabBarController()

    // Cada tab conserva su propia pila de navegación
    private let dashboardNav = UINavigationController()
    private let productsNav  = UINavigationController()
    private let clientsNav   = UINavigationController()
    private let salesNav     = UINavigationController()
    private let mapNav       = UINavigationController()
    private let settingsNav  = UINavigationController()

    // MARK: - Init

    init(container: DIContainer) {
        self.container = container
        self.navigationController = UINavigationController()
    }

    // MARK: - Coordinator

    func start() {
        tabBarController.viewControllers = [
            makeDashboardTab(),
            makeProductsTab(),
            makeClientsTab(),
            makeSalesTab(),
            makeMapTab(),
            makeSettingsTab()
        ]
        tabBarController.tabBar.tintColor = .systemBlue
    }

    // MARK: - Logout

    func logout() {
        onLogout?()
    }

    // MARK: - Tab 0 — Dashboard

    private func makeDashboardTab() -> UIViewController {
        let viewModel = DashboardViewModel(
            productService: container.productService,
            clientService:  container.clientService,
            saleService:    container.saleService
        )
        let vc = UIHostingController(rootView: DashboardView(viewModel: viewModel))
        vc.tabBarItem = UITabBarItem(
            title: "Inicio",
            image: UIImage(systemName: "house.fill"),
            tag: 0
        )
        dashboardNav.viewControllers = [vc]
        return dashboardNav
    }

    // MARK: - Tab 1 — Productos

    private func makeProductsTab() -> UIViewController {
        let viewModel = ProductListViewModel(service: container.productService)
        let view = ProductListView(
            viewModel: viewModel,
            onAdd:  { [weak self] in self?.showProductForm(product: nil) },
            onEdit: { [weak self] product in self?.showProductForm(product: product) }
        )
        let vc = UIHostingController(rootView: view)
        vc.tabBarItem = UITabBarItem(
            title: "Productos",
            image: UIImage(systemName: "cube.box.fill"),
            tag: 1
        )
        productsNav.viewControllers = [vc]
        return productsNav
    }

    private func showProductForm(product: Producto?) {
        let viewModel = ProductFormViewModel(
            service: container.productService,
            product: product
        )
        let formView = ProductFormView(
            viewModel: viewModel,
            onSave:   { [weak self] in self?.productsNav.popViewController(animated: true) },
            onCancel: { [weak self] in self?.productsNav.popViewController(animated: true) }
        )
        let vc = UIHostingController(rootView: formView)
        vc.title = product == nil ? "Nuevo Producto" : "Editar Producto"
        productsNav.pushViewController(vc, animated: true)
    }

    // MARK: - Tab 2 — Clientes

    private func makeClientsTab() -> UIViewController {
        let viewModel = ClientListViewModel(service: container.clientService)
        let view = ClientListView(
            viewModel: viewModel,
            onAdd:  { [weak self] in self?.showClientForm(client: nil) },
            onEdit: { [weak self] client in self?.showClientForm(client: client) }
        )
        let vc = UIHostingController(rootView: view)
        vc.tabBarItem = UITabBarItem(
            title: "Clientes",
            image: UIImage(systemName: "person.2.fill"),
            tag: 2
        )
        clientsNav.viewControllers = [vc]
        return clientsNav
    }

    private func showClientForm(client: Cliente?) {
        let viewModel = ClientFormViewModel(
            service: container.clientService,
            client: client
        )
        let formView = ClientFormView(
            viewModel: viewModel,
            onSave:   { [weak self] in self?.clientsNav.popViewController(animated: true) },
            onCancel: { [weak self] in self?.clientsNav.popViewController(animated: true) }
        )
        let vc = UIHostingController(rootView: formView)
        vc.title = client == nil ? "Nuevo Cliente" : "Editar Cliente"
        clientsNav.pushViewController(vc, animated: true)
    }

    // MARK: - Tab 3 — Ventas

    private func makeSalesTab() -> UIViewController {
        let viewModel = SaleListViewModel(
            saleService:    container.saleService,
            productService: container.productService,
            clientService:  container.clientService
        )
        let view = SaleListView(
            viewModel: viewModel,
            onCreate: { [weak self] in self?.showSaleForm() }
        )
        let vc = UIHostingController(rootView: view)
        vc.tabBarItem = UITabBarItem(
            title: "Ventas",
            image: UIImage(systemName: "cart.fill"),
            tag: 3
        )
        salesNav.viewControllers = [vc]
        return salesNav
    }

    private func showSaleForm() {
        let viewModel = SaleFormViewModel(
            saleService: container.saleService,
            clientService: container.clientService,
            productService: container.productService
        )
        let formView = SaleFormView(
            viewModel: viewModel,
            onSave:   { [weak self] in self?.salesNav.popViewController(animated: true) },
            onCancel: { [weak self] in self?.salesNav.popViewController(animated: true) }
        )
        let vc = UIHostingController(rootView: formView)
        vc.title = "Nueva Venta"
        salesNav.pushViewController(vc, animated: true)
    }

    // MARK: - Tab 4 — Mapa

    private func makeMapTab() -> UIViewController {
        let viewModel = MapViewModel(locationService: container.locationService)
        let mapVC = MapContainerViewController(viewModel: viewModel)
        mapVC.tabBarItem = UITabBarItem(
            title: "Mapa",
            image: UIImage(systemName: "map.fill"),
            tag: 4
        )
        mapNav.viewControllers = [mapVC]
        return mapNav
    }

    // MARK: - Tab 5 — Más / Settings

    private func makeSettingsTab() -> UIViewController {
        let viewModel = SettingsViewModel(
            productService: container.productService,
            clientService:  container.clientService,
            saleService:    container.saleService
        )
        viewModel.onLogout             = { [weak self] in self?.logout() }
        viewModel.onNavigateToReports  = { [weak self] in self?.showReports() }
        viewModel.onNavigateToAbout    = { [weak self] in self?.showAbout() }
        let vc = UIHostingController(rootView: SettingsView(viewModel: viewModel))
        vc.tabBarItem = UITabBarItem(
            title: "Configuración",
            image: UIImage(systemName: "ellipsis.circle.fill"),
            tag: 5
        )
        settingsNav.viewControllers = [vc]
        return settingsNav
    }

    private func showReports() {
        let viewModel = ReportsViewModel(
            saleService:    container.saleService,
            productService: container.productService,
            clientService:  container.clientService
        )
        let vc = UIHostingController(rootView: ReportsView(viewModel: viewModel))
        vc.title = "Reportes"
        settingsNav.pushViewController(vc, animated: true)
    }

    private func showAbout() {
        let vc = UIHostingController(rootView: AboutView())
        vc.title = "Acerca de"
        settingsNav.pushViewController(vc, animated: true)
    }
}
