import Foundation
import Combine
import CoreLocation

final class ClientFormViewModel: ObservableObject {

    // MARK: - Published State

    @Published var dni: String = ""
    @Published var nombres: String = ""
    @Published var apellidos: String = ""
    @Published var telefono: String = ""
    @Published var correo: String = ""
    @Published var direccion: String = ""
    @Published var estado: Bool = true
    @Published var errorMessage: String? = nil
    @Published var isFormValid: Bool = false

    // Location
    @Published var latitud: Double? = nil
    @Published var longitud: Double? = nil
    @Published var ubicacionDireccion: String? = nil
    @Published var isLoadingLocation: Bool = false
    @Published var locationError: String? = nil

    // MARK: - Properties

    var isEditing: Bool { client != nil }
    var onSave: (() -> Void)?

    // MARK: - Private

    private var client: Cliente?
    private let clientService: ClientServiceProtocol
    private let locationService: LocationServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(service: ClientServiceProtocol,
         locationService: LocationServiceProtocol,
         client: Cliente? = nil) {
        self.clientService = service
        self.locationService = locationService
        self.client = client

        if let client {
            dni       = client.dni
            nombres   = client.nombres
            apellidos = client.apellidos
            telefono  = client.telefono  ?? ""
            correo    = client.correo    ?? ""
            direccion = client.direccion ?? ""
            estado    = client.estado
            latitud             = client.latitud
            longitud            = client.longitud
            ubicacionDireccion  = client.ubicacionDireccion
        }

        $dni.combineLatest($nombres, $apellidos)
            .map { dni, nombres, apellidos in
                dni.count == 8 && dni.allSatisfy(\.isNumber)
                && nombres.count >= 2
                && apellidos.count >= 2
            }
            .assign(to: &$isFormValid)
    }

    // MARK: - Location Actions

    func captureCurrentLocation() {
        isLoadingLocation = true
        locationError = nil
        locationService.requestPermission()
        locationService.getCurrentLocation { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoadingLocation = false
                switch result {
                case .success(let ubicacion):
                    self?.latitud            = ubicacion.latitud
                    self?.longitud           = ubicacion.longitud
                    self?.ubicacionDireccion = ubicacion.direccion
                    if let dir = ubicacion.direccion,
                       self?.direccion.isEmpty == true {
                        self?.direccion = dir
                    }
                case .failure:
                    self?.locationError = "No se pudo obtener la ubicación. Verifica los permisos de GPS."
                }
            }
        }
    }

    func clearLocation() {
        latitud            = nil
        longitud           = nil
        ubicacionDireccion = nil
    }

    // MARK: - Actions

    func save() {
        guard dni.count == 8, dni.allSatisfy(\.isNumber) else {
            errorMessage = "DNI debe tener 8 dígitos numéricos."
            return
        }
        guard nombres.count >= 2 else {
            errorMessage = "Nombres debe tener al menos 2 caracteres."
            return
        }
        guard apellidos.count >= 2 else {
            errorMessage = "Apellidos debe tener al menos 2 caracteres."
            return
        }
        if !telefono.isEmpty {
            guard telefono.count == 9, telefono.allSatisfy(\.isNumber) else {
                errorMessage = "Teléfono debe tener 9 dígitos numéricos."
                return
            }
        }
        if !correo.isEmpty {
            guard isValidEmail(correo) else {
                errorMessage = "Correo electrónico inválido."
                return
            }
        }

        errorMessage = nil

        let entity = Cliente(
            id:                  client?.id ?? UUID(),
            dni:                 dni,
            nombres:             nombres,
            apellidos:           apellidos,
            telefono:            telefono.isEmpty  ? nil : telefono,
            correo:              correo.isEmpty    ? nil : correo,
            direccion:           direccion.isEmpty ? nil : direccion,
            estado:              estado,
            latitud:             latitud,
            longitud:            longitud,
            ubicacionDireccion:  ubicacionDireccion
        )

        let result = isEditing ? clientService.update(entity) : clientService.create(entity)

        switch result {
        case .success:
            onSave?()
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
}
