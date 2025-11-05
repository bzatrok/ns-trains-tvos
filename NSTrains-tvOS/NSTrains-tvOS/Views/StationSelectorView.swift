import SwiftUI

struct StationSelectorView: View {
    @StateObject private var viewModel = StationSelectorViewModel()
    var onStationSelected: (Station) -> Void

    var body: some View {
        ZStack {
            Color.nsBlue.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("NS")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.nsYellow)
                        .kerning(8)

                    Spacer()

                    Text("SELECT STATION")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 80)
                .padding(.top, 60)
                .padding(.bottom, 60)

                // Stations grid
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .scaleEffect(2)
                        .tint(.nsYellow)
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 64))
                            .foregroundColor(.nsYellow)
                        Text("Error Loading Stations")
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundColor(.white)
                        Text(error)
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding(60)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 400), spacing: 24)
                        ], spacing: 24) {
                            ForEach(viewModel.stations) { station in
                                Button(action: {
                                    onStationSelected(station)
                                }) {
                                    StationCard(station: station)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 80)
                        .padding(.bottom, 60)
                    }
                }

                // Footer
                if !viewModel.isLoading {
                    HStack {
                        Text("\(viewModel.stations.count) stations")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.6))

                        Spacer()

                        Text("Select a station to view departures")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 80)
                    .padding(.vertical, 40)
                }
            }
        }
        .task {
            await viewModel.loadStations()
        }
    }
}

struct StationCard: View {
    let station: Station
    @Environment(\.isFocused) var isFocused

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(station.name)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Spacer()

                Text(station.code)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(isFocused ? .nsBlue : .nsYellow)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isFocused ? Color.nsYellow : Color.nsBlue)
                    )
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isFocused ? Color.nsYellow : Color.white.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.nsYellow : Color.white.opacity(0.2), lineWidth: isFocused ? 4 : 2)
        )
        .scaleEffect(isFocused ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

@MainActor
class StationSelectorViewModel: ObservableObject {
    @Published var stations: [Station] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func loadStations() async {
        isLoading = true
        errorMessage = nil

        do {
            stations = try await NSAPIService.shared.fetchStations()
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}

#Preview {
    StationSelectorView { station in
        print("Selected: \(station.name)")
    }
}
