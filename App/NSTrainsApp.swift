import SwiftUI

@main
struct NSTrainsApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
        }
    }
}

struct ContentView: View {
    @State private var selectedStation: Station?
    @State private var showStationSelector = false
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView {
                    showSplash = false
                }
                .transition(.opacity)
            } else if showStationSelector {
                StationSelectorView { station in
                    // Save selected station
                    UserDefaults.standard.set(station.code, forKey: "lastSelectedStationCode")
                    selectedStation = station
                    showStationSelector = false
                }
            } else if let station = selectedStation {
                DepartureBoardView(
                    station: station,
                    onBack: {
                        selectedStation = nil
                    },
                    onChangeStation: {
                        showStationSelector = true
                    }
                )
            } else {
                // Loading default station
                DefaultStationLoader(onStationLoaded: { station in
                    selectedStation = station
                })
            }
        }
        .navigationBarHidden(true)
    }
}

struct DefaultStationLoader: View {
    @StateObject private var viewModel = DefaultStationViewModel()
    let onStationLoaded: (Station) -> Void

    var body: some View {
        ZStack {
            Color.nsBlue.ignoresSafeArea()

            VStack(spacing: 40) {
                Text("NS")
                    .font(.system(size: 120, weight: .bold))
                    .foregroundColor(.nsYellow)
                    .kerning(8)

                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.nsYellow)
                    Text("Loading nearest station...")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                } else if let error = viewModel.error {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 64))
                            .foregroundColor(.nsYellow)
                        Text("Error loading station")
                            .font(.system(size: 36))
                            .foregroundColor(.white)
                        Text(error)
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
        }
        .task {
            if let station = await viewModel.loadDefaultStation() {
                onStationLoaded(station)
            }
        }
    }
}

@MainActor
class DefaultStationViewModel: ObservableObject {
    @Published var isLoading = true
    @Published var error: String?

    private let lastStationKey = "lastSelectedStationCode"

    func loadDefaultStation() async -> Station? {
        isLoading = true
        error = nil

        do {
            let stations = try await NSAPIService.shared.fetchStations()

            // Check for last selected station
            if let lastStationCode = UserDefaults.standard.string(forKey: lastStationKey),
               let lastStation = stations.first(where: { $0.code == lastStationCode }) {
                return lastStation
            }

            // Default to Amsterdam Centraal (AMS) as it's the main hub
            if let amsterdamCentral = stations.first(where: { $0.code == "AMS" }) {
                return amsterdamCentral
            }

            // Fallback to first station if AMS not found
            if let firstStation = stations.first {
                return firstStation
            }

            error = "No stations found"
            return nil
        } catch {
            self.error = error.localizedDescription
            return nil
        }
    }
}
