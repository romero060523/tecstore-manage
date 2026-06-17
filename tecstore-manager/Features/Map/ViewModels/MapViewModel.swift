import Foundation
import Combine
import CoreLocation

final class MapViewModel: ObservableObject {

    // MARK: - Published State

    @Published var locations: [Ubicacion] = []
    @Published var currentLocation: Ubicacion? = nil
    @Published var isLoadingLocation: Bool = false
    @Published var errorMessage: String? = nil
    @Published var region: (lat: Double, lon: Double, span: Double) = (lat: -12.0464, lon: -77.0428, span: 0.05)

    // MARK: - Private

    private let locationService: LocationServiceProtocol

    // MARK: - Init

    init(locationService: LocationServiceProtocol) {
        self.locationService = locationService
        requestPermission()
        loadLocations()
    }

    // MARK: - Actions

    func requestPermission() {
        locationService.requestPermission()
    }

    func loadLocations() {
        locations = locationService.fetchAll()
    }

    func getCurrentLocation() {
        isLoadingLocation = true
        errorMessage = nil
        locationService.getCurrentLocation { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoadingLocation = false
                switch result {
                case .success(let ubicacion):
                    self.currentLocation = ubicacion
                    self.region = (lat: ubicacion.latitud, lon: ubicacion.longitud, span: 0.01)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    @discardableResult
    func saveCurrentLocation() -> Bool {
        guard let location = currentLocation else { return false }
        switch locationService.saveLocation(location) {
        case .success:
            currentLocation = nil
            loadLocations()
            errorMessage = nil
            return true
        case .failure:
            errorMessage = "No se pudo guardar la ubicación. Intenta de nuevo."
            return false
        }
    }
}
