// ViewModel de login: valida credenciales y expone estado reactivo mediante Combine.
import Combine
import Foundation

final class LoginViewModel: ObservableObject {

    // MARK: - Published State

    @Published var username: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var isLoginEnabled: Bool = false

    // MARK: - Callbacks

    var onLoginSuccess: (() -> Void)?

    // MARK: - Private

    private let authService: AuthServiceProtocol

    // MARK: - Init

    init(authService: AuthServiceProtocol) {
        self.authService = authService

        Publishers.CombineLatest($username, $password)
            .map { username, password in
                !username.isEmpty && username.count >= AppConstants.minUsernameLength
                    && !password.isEmpty && password.count >= AppConstants.minPasswordLength
            }
            .assign(to: &$isLoginEnabled)
    }

    // MARK: - Actions

    func login() {
        guard username.count >= AppConstants.minUsernameLength else {
            errorMessage = "El usuario debe tener al menos \(AppConstants.minUsernameLength) caracteres."
            return
        }
        guard password.count >= AppConstants.minPasswordLength else {
            errorMessage = "La contraseña debe tener al menos \(AppConstants.minPasswordLength) caracteres."
            return
        }

        isLoading = true
        errorMessage = nil

        let result = authService.authenticate(username: username, password: password)

        switch result {
        case .success(let user):
            isLoading = false
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(user.id.uuidString, forKey: "currentUserId")
            onLoginSuccess?()

        case .failure(let error):
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
}
