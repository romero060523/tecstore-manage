// Autenticación por username con contraseña almacenada como hash SHA-256.
import CryptoKit
import Foundation

final class AuthService: AuthServiceProtocol {

    // MARK: - Properties

    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    // MARK: - AuthServiceProtocol

    func authenticate(username: String, password: String) -> Result<Usuario, AuthError> {
        guard let entity = repository.find(byUsername: username) else {
            return .failure(.invalidCredentials)
        }
        guard entity.password == sha256(password) else {
            return .failure(.invalidCredentials)
        }
        guard entity.estado else {
            return .failure(.userInactive)
        }
        return .success(entity.toDomain())
    }

    func createDefaultAdmin() {
        guard repository.find(byUsername: "admin") == nil else { return }
        try? repository.create(
            username: "admin",
            password: sha256("admin123"),
            fullName: "Administrador",
            estado: true
        )
    }

    // MARK: - Private

    private func sha256(_ input: String) -> String {
        let digest = SHA256.hash(data: Data(input.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
