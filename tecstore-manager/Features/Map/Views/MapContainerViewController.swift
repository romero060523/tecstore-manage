import UIKit
import MapKit
import Combine

// MARK: - MapContainerViewController

final class MapContainerViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: MapViewModel
    private let mapView   = MKMapView()
    private var cancellables = Set<AnyCancellable>()

    private let locationButton  = UIButton(type: .system)
    private let saveButton      = UIButton(type: .system)
    private let activityContainer = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Init

    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Mapa de Ubicaciones"
        setupMapView()
        setupFloatingButtons()
        setupActivityIndicator()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupMapView() {
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupFloatingButtons() {
        configureFloatingButton(locationButton, icon: "location.fill", bgColor: .systemBackground, tint: .systemBlue)
        configureFloatingButton(saveButton, icon: "square.and.arrow.down", bgColor: .systemBlue, tint: .white)
        saveButton.isHidden = true

        view.addSubview(saveButton)
        view.addSubview(locationButton)

        NSLayoutConstraint.activate([
            locationButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            locationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            locationButton.widthAnchor.constraint(equalToConstant: 50),
            locationButton.heightAnchor.constraint(equalToConstant: 50),

            saveButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            saveButton.bottomAnchor.constraint(equalTo: locationButton.topAnchor, constant: -12),
            saveButton.widthAnchor.constraint(equalToConstant: 50),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        locationButton.addTarget(self, action: #selector(getCurrentLocationTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveLocationTapped), for: .touchUpInside)
    }

    private func configureFloatingButton(_ button: UIButton, icon: String, bgColor: UIColor, tint: UIColor) {
        button.setImage(UIImage(systemName: icon, withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)), for: .normal)
        button.backgroundColor       = bgColor
        button.tintColor             = tint
        button.layer.cornerRadius    = 25
        button.layer.shadowColor     = UIColor.black.cgColor
        button.layer.shadowOpacity   = 0.25
        button.layer.shadowOffset    = CGSize(width: 0, height: 2)
        button.layer.shadowRadius    = 4
        button.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setupActivityIndicator() {
        activityContainer.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.85)
        activityContainer.layer.cornerRadius = 12
        activityContainer.isHidden = true
        activityContainer.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        activityContainer.addSubview(activityIndicator)
        view.addSubview(activityContainer)

        NSLayoutConstraint.activate([
            activityContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityContainer.widthAnchor.constraint(equalToConstant: 80),
            activityContainer.heightAnchor.constraint(equalToConstant: 80),
            activityIndicator.centerXAnchor.constraint(equalTo: activityContainer.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: activityContainer.centerYAnchor)
        ])
    }

    // MARK: - Bindings

    private func bindViewModel() {
        // Locations + currentLocation → refresh annotations
        viewModel.$locations
            .combineLatest(viewModel.$currentLocation)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in self?.updateAnnotations() }
            .store(in: &cancellables)

        // Region → center map
        viewModel.$region
            .receive(on: DispatchQueue.main)
            .sink { [weak self] region in
                let center = CLLocationCoordinate2D(latitude: region.lat, longitude: region.lon)
                let span   = MKCoordinateSpan(latitudeDelta: region.span, longitudeDelta: region.span)
                self?.mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
            }
            .store(in: &cancellables)

        // Loading → activity indicator
        viewModel.$isLoadingLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                guard let self else { return }
                activityContainer.isHidden = !loading
                loading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
            }
            .store(in: &cancellables)

        // currentLocation → show/hide save button
        viewModel.$currentLocation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] location in
                UIView.animate(withDuration: 0.2) {
                    self?.saveButton.isHidden = (location == nil)
                }
            }
            .store(in: &cancellables)

        // Error → alert
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] message in self?.showAlert(title: "Error", message: message) }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func getCurrentLocationTapped() {
        viewModel.getCurrentLocation()
    }

    @objc private func saveLocationTapped() {
        let saved = viewModel.saveCurrentLocation()
        if saved {
            showAlert(title: "Guardado", message: "Ubicación guardada correctamente.")
        }
        // Failure path: $errorMessage binding shows the error alert
    }

    // MARK: - Annotations

    private func updateAnnotations() {
        let toRemove = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(toRemove)

        for loc in viewModel.locations {
            let ann = LocationAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: loc.latitud, longitude: loc.longitud),
                title:      loc.direccion ?? "Ubicación guardada",
                subtitle:   DateFormatter.localizedString(from: loc.fecha, dateStyle: .short, timeStyle: .short),
                isCurrent:  false
            )
            mapView.addAnnotation(ann)
        }

        if let current = viewModel.currentLocation {
            let ann = LocationAnnotation(
                coordinate: CLLocationCoordinate2D(latitude: current.latitud, longitude: current.longitud),
                title:      "📍 Ubicación actual",
                subtitle:   current.direccion ?? "Sin dirección",
                isCurrent:  true
            )
            mapView.addAnnotation(ann)
        }
    }

    // MARK: - Helpers

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - MKMapViewDelegate

extension MapContainerViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let locAnnotation = annotation as? LocationAnnotation else { return nil }

        let id = locAnnotation.isCurrent ? "current" : "saved"
        var markerView = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView

        if markerView == nil {
            markerView = MKMarkerAnnotationView(annotation: locAnnotation, reuseIdentifier: id)
            markerView?.canShowCallout = true
        } else {
            markerView?.annotation = locAnnotation
        }

        if locAnnotation.isCurrent {
            markerView?.markerTintColor = .systemGreen
            markerView?.glyphImage      = UIImage(systemName: "location.fill")
        } else {
            markerView?.markerTintColor = .systemRed
            markerView?.glyphImage      = UIImage(systemName: "mappin")
        }

        return markerView
    }
}

// MARK: - LocationAnnotation

final class LocationAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title:      String?
    let subtitle:   String?
    let isCurrent:  Bool

    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?, isCurrent: Bool) {
        self.coordinate = coordinate
        self.title      = title
        self.subtitle   = subtitle
        self.isCurrent  = isCurrent
    }
}
