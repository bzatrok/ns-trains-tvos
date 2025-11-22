import SwiftUI

struct DepartureBoardView: View {
    let station: Station
    @StateObject private var viewModel: DepartureBoardViewModel
    @State private var showingDepartures = true
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
                HStack(alignment: .center) {
                    // Departures/Arrivals Toggle
                    HStack(spacing: 16) {
                        Button(action: {
                            showingDepartures = true
                        }) {
                            Text("DEPARTURES")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(showingDepartures ? .nsBlue : .nsYellow)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                        }
                        .background(showingDepartures ? Color.nsYellow : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .buttonStyle(PlainButtonStyle())

                        Button(action: {
                            showingDepartures = false
                        }) {
                            Text("ARRIVALS")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(!showingDepartures ? .nsBlue : .nsYellow)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                        }
                        .background(!showingDepartures ? Color.nsYellow : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .buttonStyle(PlainButtonStyle())
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(station.name.uppercased())
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.nsYellow)

                        Text(showingDepartures ? "DEPARTURES" : "ARRIVALS")
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

                // Main content: Departures (left 2/3) + Map (right 1/3)
                HStack(spacing: 10) {
                    // Left side: Departures list (2/3 width)
                    VStack(spacing: 0) {
                        if let error = viewModel.errorMessage {
                            // Error state
                            VStack(spacing: 20) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 64))
                                    .foregroundColor(.nsYellow)
                                Text("Error Loading \(showingDepartures ? "Departures" : "Arrivals")")
                                    .font(.system(size: 42, weight: .semibold))
                                    .foregroundColor(.white)
                                Text(error)
                                    .font(.system(size: 28))
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(60)
                        } else {
                            VStack(spacing: 0) {
                                // Table header (single instance, always present)
                                HStack(spacing: 20) {
                                Text("TIME")
                                    .frame(width: 120, alignment: .leading)
                                Text("TRAIN")
                                    .frame(width: 100, alignment: .leading)
                                Text("TYPE")
                                    .frame(width: 160, alignment: .leading)
                                Text(showingDepartures ? "DESTINATION" : "ORIGIN")
                                    .frame(minWidth: 300, alignment: .leading)
                                Text("PLATFORM")
                                    .frame(width: 140, alignment: .center)
                                Text("DELAY")
                                    .frame(width: 100, alignment: .center)
                                Text("STATUS")
                                    .frame(width: 140, alignment: .center)
                            }
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.nsYellow)
                            .padding(.horizontal, 16)
                            .background(Color.white.opacity(0.1))
                            .frame(height: 56)

                            // Row container - Fixed height to prevent layout shifts
                            VStack(spacing: 2) {
                                ForEach(0..<7, id: \.self) { index in
                                    if viewModel.isLoading {
                                        DepartureSkeletonRow()
                                            .id("row-\(index)")
                                    } else if index < viewModel.departures.count {
                                        DepartureRow(departure: viewModel.departures[index])
                                            .id("row-\(index)")
                                    } else {
                                        Color.clear
                                            .frame(height: 68)
                                            .id("row-\(index)")
                                    }
                                }
                            }
                            .frame(height: 476)
                            .padding(.horizontal, 16)
                            .animation(.easeInOut(duration: 0.4), value: viewModel.isLoading)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 532)
                    .layoutPriority(2)

                    // Right side: Train Map (1/3 width)
                    TrainMapCompactView(station: station)
                        .frame(width: 500)
                        .frame(height: 532)
                        .layoutPriority(1)
                }
                .padding(.horizontal, 14) // 14px + 16px internal = 30px total alignment

                // Footer - Only shown when not loading
                if !viewModel.isLoading {
                    HStack {
                        Text("Showing \(min(7, viewModel.departures.count)) of \(viewModel.departures.count) \(showingDepartures ? "departures" : "arrivals")")
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
        .onChange(of: showingDepartures) { _, newValue in
            Task {
                await viewModel.loadJourneys(showingDepartures: newValue)
            }
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
        HStack(spacing: 20) {
            // Time
            Text(timeString)
                .font(.system(size: 30, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 120, alignment: .leading)

            // Train
            Text(departure.trainNumber)
                .font(.system(size: 26))
                .foregroundColor(.white)
                .frame(width: 100, alignment: .leading)

            // Type
            Text(departure.trainType)
                .font(.system(size: 26))
                .foregroundColor(.white)
                .frame(width: 160, alignment: .leading)
                .lineLimit(1)

            // Destination
            VStack(alignment: .leading, spacing: 2) {
                Text(departure.destination)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)

                if !departure.via.isEmpty {
                    Text("via \(departure.via)")
                        .font(.system(size: 22))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
            }
            .frame(minWidth: 300, alignment: .leading)

            // Platform
            Text(departure.platform)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(departure.platformChanged ? .nsYellow : .white)
                .frame(width: 140, alignment: .center)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(departure.platformChanged ? Color.nsYellow.opacity(0.2) : Color.clear)
                )

            // Delay
            Text(departure.delay > 0 ? "+\(departure.delay)" : "-")
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(departure.delay > 0 ? .nsYellow : .white.opacity(0.5))
                .frame(width: 100, alignment: .center)

            // Status
            Text(statusText)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(statusColor)
                .frame(width: 140, alignment: .center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 22)
        .background(
            RoundedRectangle(cornerRadius: 0)
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
    @Published var showingDepartures = true

    private var refreshTimer: Timer?
    private var loadingStartTime: Date?

    init(stationCode: String) {
        self.stationCode = stationCode
    }

    func loadDepartures() async {
        isLoading = true
        errorMessage = nil
        loadingStartTime = Date()

        do {
            departures = try await NSAPIService.shared.fetchDepartures(for: stationCode)
            updateLastUpdateTime()
            await enforceMinimumLoadingTime()
            isLoading = false
            startAutoRefresh()
        } catch {
            errorMessage = error.localizedDescription
            await enforceMinimumLoadingTime()
            isLoading = false
        }
    }

    func loadArrivals() async {
        isLoading = true
        errorMessage = nil
        loadingStartTime = Date()

        do {
            departures = try await NSAPIService.shared.fetchArrivals(for: stationCode)
            updateLastUpdateTime()
            await enforceMinimumLoadingTime()
            isLoading = false
            startAutoRefresh()
        } catch {
            errorMessage = error.localizedDescription
            await enforceMinimumLoadingTime()
            isLoading = false
        }
    }

    func loadJourneys(showingDepartures: Bool) async {
        if showingDepartures {
            await loadDepartures()
        } else {
            await loadArrivals()
        }
    }

    private func startAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshJourneys()
            }
        }
    }

    private func refreshJourneys() async {
        isRefreshing = true

        do {
            if showingDepartures {
                departures = try await NSAPIService.shared.fetchDepartures(for: stationCode)
            } else {
                departures = try await NSAPIService.shared.fetchArrivals(for: stationCode)
            }
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

    private func enforceMinimumLoadingTime() async {
        guard let startTime = loadingStartTime else { return }

        let elapsed = Date().timeIntervalSince(startTime)
        let minimumDuration: TimeInterval = 1.5 // 1500ms

        if elapsed < minimumDuration {
            let remainingTime = minimumDuration - elapsed
            try? await Task.sleep(nanoseconds: UInt64(remainingTime * 1_000_000_000))
        }
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
