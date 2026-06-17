import Foundation
import Combine

final class ProductListViewModel: ObservableObject {

    // MARK: - Published State

    @Published var products: [Producto] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String? = nil
    @Published var isLoading: Bool = false

    // MARK: - Constants

    let categories = ["Todas", "Electrónica", "Ropa", "Alimentos", "Hogar", "Otros"]

    // MARK: - Private

    private let productService: ProductServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(service: ProductServiceProtocol) {
        self.productService = service

        $searchText
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.loadProducts() }
            .store(in: &cancellables)

        $selectedCategory
            .dropFirst()
            .sink { [weak self] _ in self?.loadProducts() }
            .store(in: &cancellables)

        loadProducts()
    }

    // MARK: - Actions

    func loadProducts() {
        isLoading = true
        let search   = searchText.isEmpty ? nil : searchText
        let category = (selectedCategory == nil || selectedCategory == "Todas") ? nil : selectedCategory
        products = productService.fetchAll(searchText: search, category: category)
        isLoading = false
    }

    func deleteProduct(id: UUID) {
        _ = productService.delete(id: id)
        loadProducts()
    }
}
