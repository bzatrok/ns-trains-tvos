import SwiftUI
import MapKit

struct TrainMapCompactView: View {
    let station: Station
    @StateObject private var viewModel: TrainMapViewModel

    init(station: Station) {
        self.station = station
        _viewModel = StateObject(wrappedValue: TrainMapViewModel(station: station))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Map header
            HStack {
                Text("NEARBY TRAINS")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.nsYellow)

                Spacer()

                if viewModel.isRefreshing {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.nsYellow)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.nsBlue.opacity(0.8))

            // Map container
            ZStack {
                if viewModel.isLoading {
                    // Loading state
                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(.nsYellow)
                        Text("Loading trains...")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.nsBlue.opacity(0.3))
                } else if let errorMessage = viewModel.errorMessage {
                    // Error state
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.nsYellow)
                        Text(errorMessage)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.nsBlue.opacity(0.3))
                } else {
                    // Map view
                    MapViewContainer(
                        station: station,
                        trains: viewModel.trains
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.black.opacity(0.3))
        .task {
            await viewModel.loadTrains()
        }
    }
}

// MARK: - Map View Container (UIKit Wrapper)

struct MapViewContainer: UIViewRepresentable {
    let station: Station
    let trains: [Train]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = .standard

        // Register custom annotation view
        mapView.register(
            TrainAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: TrainAnnotationView.reuseIdentifier
        )

        // Set initial region centered on station (50km radius)
        let region = MKCoordinateRegion(
            center: station.coordinate,
            latitudinalMeters: 3000 * 2,  // 3km radius = 6km span
            longitudinalMeters: 3000 * 2
        )
        mapView.setRegion(region, animated: false)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Remove old annotations
        let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(existingAnnotations)

        // Add station annotation
        let stationAnnotation = MKPointAnnotation()
        stationAnnotation.coordinate = station.coordinate
        stationAnnotation.title = station.name
        mapView.addAnnotation(stationAnnotation)

        // Add train annotations
        let trainAnnotations = trains.map { train -> TrainAnnotation in
            TrainAnnotation(train: train)
        }
        mapView.addAnnotations(trainAnnotations)
    }

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator()
    }
}

// MARK: - Map Coordinator

class MapCoordinator: NSObject, MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Station annotation (default pin)
        if annotation is MKPointAnnotation {
            let identifier = "StationPin"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            annotationView?.markerTintColor = .systemBlue
            annotationView?.glyphImage = UIImage(systemName: "building.2")

            return annotationView
        }

        // Train annotation (custom view)
        if annotation is TrainAnnotation {
            guard let trainAnnotation = annotation as? TrainAnnotation else { return nil }

            let annotationView = mapView.dequeueReusableAnnotationView(
                withIdentifier: TrainAnnotationView.reuseIdentifier,
                for: trainAnnotation
            ) as? TrainAnnotationView

            return annotationView
        }

        return nil
    }
}

// MARK: - Train Annotation

class TrainAnnotation: NSObject, MKAnnotation {
    let train: Train
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?

    init(train: Train) {
        self.train = train
        self.coordinate = train.coordinate
        self.title = "\(train.typeCode) \(train.trainNumber)"
        self.subtitle = "\(train.formattedSpeed)"
        super.init()
    }
}

// MARK: - View Model

@MainActor
class TrainMapViewModel: ObservableObject {
    @Published var trains: [Train] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?

    private let station: Station
    private var refreshTimer: Timer?

    var trainCount: String {
        if trains.isEmpty {
            return "No trains"
        } else if trains.count == 1 {
            return "1 train"
        } else {
            return "\(trains.count) trains"
        }
    }

    init(station: Station) {
        self.station = station
    }

    func loadTrains() async {
        isLoading = true
        errorMessage = nil

        do {
            trains = try await NSAPIService.shared.fetchTrains(
                latitude: station.latitude,
                longitude: station.longitude,
                radius: 50,
                limit: 50
            )
            isLoading = false

            // Start auto-refresh
            startAutoRefresh()
        } catch {
            isLoading = false
            errorMessage = "Failed to load trains: \(error.localizedDescription)"
        }
    }

    func refreshTrains() async {
        isRefreshing = true

        do {
            trains = try await NSAPIService.shared.fetchTrains(
                latitude: station.latitude,
                longitude: station.longitude,
                radius: 50,
                limit: 50
            )
        } catch {
            errorMessage = "Failed to refresh: \(error.localizedDescription)"
        }

        isRefreshing = false
    }

    private func startAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshTrains()
            }
        }
    }

    deinit {
        refreshTimer?.invalidate()
    }
}
