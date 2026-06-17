import Foundation
import Combine

final class ProductFormViewModel: ObservableObject {

    // MARK: - Published State

    @Published var codigo: String = ""
    @Published var nombre: String = ""
    @Published var categoria: String = "Electrónica"
    @Published var precio: String = ""
    @Published var stock: String = ""
    @Published var estado: Bool = true
    @Published var errorMessage: String? = nil
    @Published var isFormValid: Bool = false

    // MARK: - Properties

    var isEditing: Bool { product != nil }
    private(set) var product: Producto?
    let categories = ["Electrónica", "Ropa", "Alimentos", "Hogar", "Otros"]
    var onSave: (() -> Void)?

    // MARK: - Private

    private let productService: ProductServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(service: ProductServiceProtocol, product: Producto?) {
        self.productService = service
        self.product = product

        if let product {
            codigo    = product.codigo
            nombre    = product.nombre
            categoria = product.categoria
            precio    = String(product.precio)
            stock     = String(product.stock)
            estado    = product.estado
        }

        $nombre.combineLatest($precio, $stock)
            .map { nombre, precio, stock in
                !nombre.isEmpty &&
                (Double(precio) ?? -1) > 0 &&
                (Int(stock) ?? -1) >= 0
            }
            .assign(to: &$isFormValid)
    }

    // MARK: - Actions

    func save() {
        guard !nombre.isEmpty else {
            errorMessage = "El nombre no puede estar vacío."
            return
        }
        guard let precioVal = Double(precio), precioVal > 0 else {
            errorMessage = "El precio debe ser mayor a 0."
            return
        }
        guard let stockVal = Int32(stock), stockVal >= 0 else {
            errorMessage = "El stock no puede ser negativo."
            return
        }

        errorMessage = nil

        if isEditing, let product {
            let updated = Producto(
                id:            product.id,
                codigo:        codigo.isEmpty ? product.codigo : codigo,
                nombre:        nombre,
                categoria:     categoria,
                precio:        precioVal,
                stock:         stockVal,
                fechaRegistro: product.fechaRegistro,
                estado:        estado
            )
            switch productService.update(updated) {
            case .success:  onSave?()
            case .failure(let e): errorMessage = e.localizedDescription
            }
        } else {
            let newCodigo = codigo.isEmpty ? "PROD-\(Int.random(in: 1000...9999))" : codigo
            let nuevo = Producto(
                id:            UUID(),
                codigo:        newCodigo,
                nombre:        nombre,
                categoria:     categoria,
                precio:        precioVal,
                stock:         stockVal,
                fechaRegistro: Date(),
                estado:        estado
            )
            switch productService.create(nuevo) {
            case .success:  onSave?()
            case .failure(let e): errorMessage = e.localizedDescription
            }
        }
    }
}
