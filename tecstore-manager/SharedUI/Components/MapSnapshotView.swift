import SwiftUI
import MapKit

struct MapSnapshotView: View {
    let latitude: Double
    let longitude: Double

    @State private var snapshotImage: UIImage? = nil
    @State private var isLoading: Bool = true

    var body: some View {
        ZStack {
            if let image = snapshotImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if isLoading {
                ZStack {
                    Color(.systemGray6)
                    ProgressView()
                }
            } else {
                ZStack {
                    Color(.systemGray6)
                    VStack(spacing: 8) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                        Text(String(format: "%.4f, %.4f", latitude, longitude))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Image(systemName: "mappin.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(AppColors.danger)
                .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
        }
        .onAppear { generateSnapshot() }
        .onChange(of: latitude) { _ in generateSnapshot() }
        .onChange(of: longitude) { _ in generateSnapshot() }
    }

    private func generateSnapshot() {
        isLoading = true
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        )
        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = CGSize(width: 400, height: 200)
        options.scale = UIScreen.main.scale
        options.mapType = .standard

        MKMapSnapshotter(options: options).start { snapshot, _ in
            DispatchQueue.main.async {
                isLoading = false
                if let snapshot = snapshot {
                    snapshotImage = snapshot.image
                }
            }
        }
    }
}
