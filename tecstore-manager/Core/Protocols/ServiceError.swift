// Errores tipados compartidos por todos los servicios de la aplicación.
import Foundation

enum ServiceError: LocalizedError {
    case notFound
    case saveFailed
    case deleteFailed
    case validationError(String)
    case insufficientStock

    var errorDescription: String? {
        switch self {
        case .notFound:                 return "Registro no encontrado."
        case .saveFailed:               return "No se pudo guardar el registro."
        case .deleteFailed:             return "No se pudo eliminar el registro."
        case .validationError(let msg): return msg
        case .insufficientStock:        return "Stock insuficiente para realizar la venta."
        }
    }
}
