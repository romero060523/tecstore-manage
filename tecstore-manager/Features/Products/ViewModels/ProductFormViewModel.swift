import SwiftUI
import PhotosUI
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
    @Published var imagenData: Data? = nil
    @Published var selectedPhotoItem: PhotosPickerItem? = nil

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
            imagenData = product.imagenData
        }

        $nombre.combineLatest($precio, $stock)
            .map { nombre, precio, stock in
                !nombre.isEmpty &&
                (Double(precio) ?? -1) > 0 &&
                (Int(stock) ?? -1) >= 0
            }
            .assign(to: &$isFormValid)

        $selectedPhotoItem
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.loadSelectedImage()
            }
            .store(in: &cancellables)
    }

    // MARK: - Image Actions

    func loadSelectedImage() {
        guard let item = selectedPhotoItem else { return }
        Task { @MainActor in
            if let data = try? await item.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data),
                   let compressed = uiImage.jpegData(compressionQuality: 0.6) {
                    self.imagenData = compressed
                } else {
                    self.imagenData = data
                }
            }
        }
    }

    func removeImage() {
        imagenData = nil
        selectedPhotoItem = nil
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
                estado:        estado,
                imagenData:    imagenData
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
                estado:        estado,
                imagenData:    imagenData
            )
            switch productService.create(nuevo) {
            case .success:  onSave?()
            case .failure(let e): errorMessage = e.localizedDescription
            }
        }
    }
}
