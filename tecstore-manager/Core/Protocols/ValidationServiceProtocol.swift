// Contrato para las validaciones puras de datos de entrada.
import Foundation

protocol ValidationServiceProtocol {
    func validateDNI(_ dni: String) -> ValidationResult
    func validateEmail(_ email: String) -> ValidationResult
    func validatePrice(_ price: Double) -> ValidationResult
    func validateStock(_ stock: Int) -> ValidationResult
    func validateQuantity(_ quantity: Int, availableStock: Int) -> ValidationResult
    func validateRequired(_ value: String, fieldName: String) -> ValidationResult
}

// MARK: - ValidationResult

enum ValidationResult {
    case valid
    case invalid(String)

    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }

    var errorMessage: String? {
        if case .invalid(let message) = self { return message }
        return nil
    }
}
