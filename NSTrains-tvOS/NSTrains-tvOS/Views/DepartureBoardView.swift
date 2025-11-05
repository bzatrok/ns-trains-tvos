import SwiftUI

struct DepartureBoardView: View {
    let station: Station
    @StateObject private var viewModel: DepartureBoardViewModel
    var onBack: (() -> Void)?
    var onChangeStation: (() -> Void)?

    init(station: Station, onBack: (() -> Void)? = nil, onChangeStation: (() -> Void)? = nil) {
        self.station = station
        self.onBack = onBack
        self.onChangeStation = onChangeStation
        _viewModel = StateObject(wrappedValue: DepartureBoardViewModel(stationCode: station.code))
    }

    var body: some View {
        ZStack {
            Color.nsBlue.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    if let onBack = onBack {
                        Button(action: onBack) {
                            HStack(spacing: 12) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 32, weight: .semibold))
                                Text("BACK")
                                    .font(.system(size: 32, weight: .semibold))
                            }
                            .foregroundColor(.nsYellow)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(station.name.uppercased())
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.nsYellow)

                        Text("DEPARTURES")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button(action: { onChangeStation?() }) {
                        HStack(spacing: 12) {
                            Image(systemName: "map")
                                .font(.system(size: 32, weight: .semibold))
                            Text("CHANGE")
                                .font(.system(size: 32, weight: .semibold))
                        }
                        .foregroundColor(.nsYellow)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 30)
                .padding(.top, 60)
                .padding(.bottom, 20)

                // Last update
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.nsYellow)
                    Text("Last update: \(viewModel.lastUpdateTime)")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()

                    if viewModel.isRefreshing {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.nsYellow)
                        Text("Refreshing...")
                            .font(.system(size: 24))
                            .foregroundColor(.nsYellow)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)

                // Departures list
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
                        Text("Error Loading Departures")
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
                    // Table header
                    HStack(spacing: 30) {
                        Text("TIME")
                            .frame(width: 140, alignment: .leading)
                        Text("TRAIN")
                            .frame(width: 120, alignment: .leading)
                        Text("TYPE")
                            .frame(width: 200, alignment: .leading)
                        Text("DESTINATION")
                            .frame(minWidth: 400, alignment: .leading)
                        Text("PLATFORM")
                            .frame(width: 180, alignment: .center)
                        Text("DELAY")
                            .frame(width: 120, alignment: .center)
                        Text("STATUS")
                            .frame(width: 160, alignment: .center)
                    }
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.nsYellow)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
                    .background(Color.white.opacity(0.1))

                    // Departures
                    ScrollView {
                        VStack(spacing: 2) {
                            ForEach(viewModel.departures) { departure in
                                DepartureRow(departure: departure)
                            }
                        }
                        .padding(.horizontal, 30)
                    }
                }

                // Footer
                if !viewModel.isLoading {
                    HStack {
                        Text("\(viewModel.departures.count) departures")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.6))

                        Spacer()

                        Text("Auto-refresh: 30s")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 30)
                }
            }
        }
        .task {
            await viewModel.loadDepartures()
        }
    }
}

struct DepartureRow: View {
    let departure: Departure

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: departure.departureTime)
    }

    var statusColor: Color {
        if departure.cancelled { return .red }
        if departure.delay > 5 { return .red }
        return .green
    }

    var statusText: String {
        if departure.cancelled { return "CANCELLED" }
        if departure.delay > 0 { return "DELAYED" }
        return "ON TIME"
    }

    var body: some View {
        HStack(spacing: 30) {
            // Time
            Text(timeString)
                .font(.system(size: 36, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 140, alignment: .leading)

            // Train
            Text(departure.trainNumber)
                .font(.system(size: 32))
                .foregroundColor(.white)
                .frame(width: 120, alignment: .leading)

            // Type
            Text(departure.trainType)
                .font(.system(size: 32))
                .foregroundColor(.white)
                .frame(width: 200, alignment: .leading)
                .lineLimit(1)

            // Destination
            VStack(alignment: .leading, spacing: 4) {
                Text(departure.destination)
                    .font(.system(size: 34, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                if !departure.via.isEmpty {
                    Text("via \(departure.via)")
                        .font(.system(size: 26))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .frame(minWidth: 400, alignment: .leading)

            // Platform
            Text(departure.platform)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(departure.platformChanged ? .nsYellow : .white)
                .frame(width: 180, alignment: .center)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(departure.platformChanged ? Color.nsYellow.opacity(0.2) : Color.clear)
                )

            // Delay
            Text(departure.delay > 0 ? "+\(departure.delay)" : "-")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(departure.delay > 0 ? .nsYellow : .white.opacity(0.5))
                .frame(width: 120, alignment: .center)

            // Status
            Text(statusText)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(statusColor)
                .frame(width: 160, alignment: .center)
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
        )
    }
}

@MainActor
class DepartureBoardViewModel: ObservableObject {
    let stationCode: String

    @Published var departures: [Departure] = []
    @Published var isLoading = false
    @Published var isRefreshing = false
    @Published var errorMessage: String?
    @Published var lastUpdateTime = "--:--:--"

    private var refreshTimer: Timer?

    init(stationCode: String) {
        self.stationCode = stationCode
    }

    func loadDepartures() async {
        isLoading = true
        errorMessage = nil

        do {
            departures = try await NSAPIService.shared.fetchDepartures(for: stationCode)
            updateLastUpdateTime()
            isLoading = false
            startAutoRefresh()
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func startAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshDepartures()
            }
        }
    }

    private func refreshDepartures() async {
        isRefreshing = true

        do {
            departures = try await NSAPIService.shared.fetchDepartures(for: stationCode)
            updateLastUpdateTime()
        } catch {
            // Silent fail on refresh - keep showing old data
            print("Refresh failed: \(error)")
        }

        isRefreshing = false
    }

    private func updateLastUpdateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        lastUpdateTime = formatter.string(from: Date())
    }

    deinit {
        refreshTimer?.invalidate()
    }
}

#Preview {
    // Note: Cannot use custom init in Preview, so we create a minimal Station
    struct PreviewStation {
        static var sample: Station {
            // Manually create a Station for preview
            let station = try! JSONDecoder().decode(Station.self, from: """
            {
                "code": "AMS",
                "namen": {"lang": "Amsterdam Centraal"},
                "land": "NL",
                "UICCode": "8400058"
            }
            """.data(using: .utf8)!)
            return station
        }
    }

    return DepartureBoardView(station: PreviewStation.sample)
}
