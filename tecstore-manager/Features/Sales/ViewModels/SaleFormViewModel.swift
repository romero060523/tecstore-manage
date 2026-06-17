import Foundation
import Combine

final class SaleFormViewModel: ObservableObject {

    // MARK: - Published State

    @Published var selectedClient: Cliente? = nil
    @Published var selectedProduct: Producto? = nil
    @Published var cantidad: String = "1"
    @Published var errorMessage: String? = nil
    @Published var isFormValid: Bool = false
    @Published var clients: [Cliente] = []
    @Published var products: [Producto] = []
    @Published var clientSearchText: String = ""
    @Published var productSearchText: String = ""

    // MARK: - Computed

    var precioUnitario: Double { selectedProduct?.precio ?? 0 }
    var cantidadInt: Int       { Int(cantidad) ?? 0 }
    var subtotal: Double       { precioUnitario * Double(cantidadInt) }
    var igv: Double            { subtotal * AppConstants.igvRate }
    var total: Double          { subtotal + igv }
    var stockDisponible: Int   { Int(selectedProduct?.stock ?? 0) }

    // MARK: - Private

    private let saleService: SaleServiceProtocol
    private let clientService: ClientServiceProtocol
    private let productService: ProductServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    var onSave: (() -> Void)?

    // MARK: - Init

    init(
        saleService: SaleServiceProtocol,
        clientService: ClientServiceProtocol,
        productService: ProductServiceProtocol
    ) {
        self.saleService    = saleService
        self.clientService  = clientService
        self.productService = productService

        clients  = clientService.fetchAll(searchText: nil).filter { $0.estado }
        products = productService.fetchAll(searchText: nil, category: nil)
            .filter { $0.estado && $0.stock > 0 }

        Publishers.CombineLatest3($selectedClient, $selectedProduct, $cantidad)
            .map { client, product, cantStr in
                guard client != nil, let product else { return false }
                let cant = Int(cantStr) ?? 0
                return cant > 0 && cant <= Int(product.stock)
            }
            .assign(to: &$isFormValid)
    }

    // MARK: - Actions

    func save() {
        guard let client = selectedClient else {
            errorMessage = "Seleccione un cliente."
            return
        }
        guard let product = selectedProduct else {
            errorMessage = "Seleccione un producto."
            return
        }
        guard cantidadInt > 0 else {
            errorMessage = "La cantidad debe ser mayor a 0."
            return
        }
        guard cantidadInt <= stockDisponible else {
            errorMessage = "Stock insuficiente (disponible: \(stockDisponible))."
            return
        }

        errorMessage = nil

        switch saleService.create(
            clienteId:  client.id,
            productoId: product.id,
            cantidad:   cantidadInt
        ) {
        case .success:       onSave?()
        case .failure(let e): errorMessage = e.localizedDescription
        }
    }
}
