// Modelos de dominio puros, sin dependencias de Core Data.
import Foundation

// MARK: - Usuario

struct Usuario: Identifiable, Hashable {
    let id: UUID
    let username: String
    let password: String
    let fullName: String
    let estado: Bool
}

// MARK: - Producto

struct Producto: Identifiable, Hashable {
    let id: UUID
    let codigo: String
    let nombre: String
    let categoria: String
    let precio: Double
    let stock: Int32
    let fechaRegistro: Date
    let estado: Bool
}

// MARK: - Cliente

struct Cliente: Identifiable, Hashable {
    let id: UUID
    let dni: String
    let nombres: String
    let apellidos: String
    let telefono: String?
    let correo: String?
    let direccion: String?
    let estado: Bool
}

// MARK: - Venta

struct Venta: Identifiable, Hashable {
    let id: UUID
    let fecha: Date
    let cantidad: Int32
    let precio: Double
    let subtotal: Double
    let igv: Double
    let total: Double
    let clienteId: UUID?
    let productoId: UUID?
}

// MARK: - Ubicacion

struct Ubicacion: Identifiable, Hashable {
    let id: UUID
    let latitud: Double
    let longitud: Double
    let direccion: String?
    let fecha: Date
}
