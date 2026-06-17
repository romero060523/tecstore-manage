// Configura la ventana principal e inicia el flujo de coordinadores.
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // MARK: - Properties

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?
    private var container: DIContainer?

    // MARK: - UIWindowSceneDelegate

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let coreDataStack = CoreDataStack()
        let container = DIContainer(coreDataStack: coreDataStack)
        self.container = container

        SeedDataManager(coreDataStack: coreDataStack).seedIfNeeded()

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let coordinator = AppCoordinator(window: window, container: container)
        self.appCoordinator = coordinator
        coordinator.start()

        window.makeKeyAndVisible()
    }

    // MARK: - Background Transitions

    func sceneDidEnterBackground(_ scene: UIScene) {
        container?.coreDataStack.saveContext()
    }
}
