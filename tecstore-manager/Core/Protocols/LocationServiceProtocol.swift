// Contrato para la obtención y persistencia de ubicaciones GPS.
import Foundation

protocol LocationServiceProtocol {
    func requestPermission()
    func getCurrentLocation(completion: @escaping (Result<Ubicacion, ServiceError>) -> Void)
    func saveLocation(_ location: Ubicacion) -> Result<Ubicacion, ServiceError>
    func fetchAll() -> [Ubicacion]
}
