// Coordinador raíz: decide entre el flujo de autenticación y la aplicación principal.
import UIKit

final class AppCoordinator: Coordinator {

    // MARK: - Coordinator

    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController

    // MARK: - Properties

    private let window: UIWindow
    private let container: DIContainer
    private static let sessionKey = "isLoggedIn"

    // MARK: - Init

    init(window: UIWindow, container: DIContainer) {
        self.window = window
        self.container = container
        self.navigationController = UINavigationController()
    }

    // MARK: - Coordinator

    func start() {
        container.authService.createDefaultAdmin()
        if UserDefaults.standard.bool(forKey: Self.sessionKey) {
            showMain()
        } else {
            showAuth()
        }
    }

    // MARK: - Private Navigation

    private func showAuth() {
        childCoordinators.removeAll()

        let navController = UINavigationController()
        navController.setNavigationBarHidden(true, animated: false)

        let authCoordinator = AuthCoordinator(
            navigationController: navController,
            container: container
        )
        authCoordinator.onLoginSuccess = { [weak self] in
            UserDefaults.standard.set(true, forKey: Self.sessionKey)
            self?.showMain()
        }
        addChild(authCoordinator)
        authCoordinator.start()

        transition(to: navController)
    }

    private func showMain() {
        childCoordinators.removeAll()

        let mainCoordinator = MainCoordinator(container: container)
        mainCoordinator.onLogout = { [weak self] in
            UserDefaults.standard.removeObject(forKey: Self.sessionKey)
            self?.showAuth()
        }
        addChild(mainCoordinator)
        mainCoordinator.start()

        transition(to: mainCoordinator.tabBarController)
    }

    private func transition(to viewController: UIViewController) {
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { self.window.rootViewController = viewController },
            completion: nil
        )
    }
}
