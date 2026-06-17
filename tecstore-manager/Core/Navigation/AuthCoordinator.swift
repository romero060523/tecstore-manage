// Coordinador de autenticación: gestiona la pantalla de inicio de sesión.
import UIKit

final class AuthCoordinator: Coordinator {

    // MARK: - Coordinator

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    // MARK: - Properties

    var onLoginSuccess: (() -> Void)?
    private let container: DIContainer

    // MARK: - Init

    init(navigationController: UINavigationController, container: DIContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    // MARK: - Coordinator

    func start() {
        let viewModel = LoginViewModel(authService: container.authService)
        let loginVC = LoginViewController(viewModel: viewModel)
        loginVC.onLoginSuccess = { [weak self] in
            self?.onLoginSuccess?()
        }
        navigationController.setViewControllers([loginVC], animated: false)
    }
}
