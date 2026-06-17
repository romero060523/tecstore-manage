// Contrato para la autenticación de usuarios en la aplicación.
import Foundation

protocol AuthServiceProtocol {
    func authenticate(username: String, password: String) -> Result<Usuario, AuthError>
    func createDefaultAdmin()
}

// MARK: - AuthError

enum AuthError: LocalizedError {
    case invalidCredentials
    case userInactive
    case unknownError

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Usuario o contraseña incorrectos."
        case .userInactive:       return "El usuario se encuentra inactivo."
        case .unknownError:       return "Error desconocido al autenticar."
        }
    }
}
