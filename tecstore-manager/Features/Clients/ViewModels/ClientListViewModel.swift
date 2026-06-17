import Foundation
import Combine

final class ClientListViewModel: ObservableObject {

    // MARK: - Published State

    @Published var clients: [Cliente] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false

    // MARK: - Private

    private let clientService: ClientServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(service: ClientServiceProtocol) {
        self.clientService = service

        $searchText
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in self?.loadClients() }
            .store(in: &cancellables)

        loadClients()
    }

    // MARK: - Actions

    func loadClients() {
        isLoading = true
        let search = searchText.isEmpty ? nil : searchText
        clients = clientService.fetchAll(searchText: search)
        isLoading = false
    }

    func deleteClient(id: UUID) {
        _ = clientService.delete(id: id)
        loadClients()
    }
}
