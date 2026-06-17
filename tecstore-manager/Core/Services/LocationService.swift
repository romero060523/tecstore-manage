// Obtención de coordenadas GPS con reverse geocoding y persistencia de ubicaciones.
import CoreLocation
import Foundation

final class LocationService: NSObject, LocationServiceProtocol {

    // MARK: - Properties

    private let repository: LocationRepository
    private let locationManager = CLLocationManager()
    private var pendingCompletion: ((Result<Ubicacion, ServiceError>) -> Void)?

    init(repository: LocationRepository) {
        self.repository = repository
        super.init()
        locationManager.delegate        = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - LocationServiceProtocol

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func getCurrentLocation(completion: @escaping (Result<Ubicacion, ServiceError>) -> Void) {
        pendingCompletion = completion
        locationManager.requestLocation()
    }

    func saveLocation(_ location: Ubicacion) -> Result<Ubicacion, ServiceError> {
        do {
            try repository.create(
                latitud:   location.latitud,
                longitud:  location.longitud,
                direccion: location.direccion
            )
            return .success(location)
        } catch {
            return .failure(.saveFailed)
        }
    }

    func fetchAll() -> [Ubicacion] {
        repository.fetchAll().map { $0.toDomain() }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let raw = locations.last else {
            pendingCompletion?(.failure(.notFound))
            pendingCompletion = nil
            return
        }

        CLGeocoder().reverseGeocodeLocation(raw) { [weak self] placemarks, _ in
            guard let self else { return }

            var parts: [String] = []
            if let placemark = placemarks?.first {
                if let street = placemark.thoroughfare    { parts.append(street) }
                if let number = placemark.subThoroughfare { parts.append(number) }
                if let city   = placemark.locality        { parts.append(city) }
            }
            let direccion = parts.isEmpty ? nil : parts.joined(separator: ", ")

            let ubicacion = Ubicacion(
                id:        UUID(),
                latitud:   raw.coordinate.latitude,
                longitud:  raw.coordinate.longitude,
                direccion: direccion,
                fecha:     Date()
            )
            self.pendingCompletion?(.success(ubicacion))
            self.pendingCompletion = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        pendingCompletion?(.failure(.saveFailed))
        pendingCompletion = nil
    }
}
