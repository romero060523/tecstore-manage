// Validaciones puras de datos de entrada: sin efectos secundarios ni dependencias externas.
import Foundation

final class ValidationService: ValidationServiceProtocol {

    // MARK: - ValidationServiceProtocol

    func validateDNI(_ dni: String) -> ValidationResult {
        let regex = #"^\d{8}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: dni)
            ? .valid
            : .invalid("El DNI debe tener exactamente 8 dígitos numéricos.")
    }

    func validateEmail(_ email: String) -> ValidationResult {
        let regex = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
            ? .valid
            : .invalid("El correo electrónico no tiene un formato válido.")
    }

    func validatePrice(_ price: Double) -> ValidationResult {
        price > 0
            ? .valid
            : .invalid("El precio debe ser mayor que 0.")
    }

    func validateStock(_ stock: Int) -> ValidationResult {
        stock >= 0
            ? .valid
            : .invalid("El stock no puede ser negativo.")
    }

    func validateQuantity(_ quantity: Int, availableStock: Int) -> ValidationResult {
        if quantity <= 0 {
            return .invalid("La cantidad debe ser mayor que 0.")
        }
        if quantity > availableStock {
            return .invalid("Stock insuficiente. Disponible: \(availableStock).")
        }
        return .valid
    }

    func validateRequired(_ value: String, fieldName: String) -> ValidationResult {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? .invalid("\(fieldName) es requerido.")
            : .valid
    }
}
