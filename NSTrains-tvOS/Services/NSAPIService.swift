import Foundation

class NSAPIService {
    static let shared = NSAPIService()

    private let baseURL = "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v2"
    private let virtualTrainURL = "https://gateway.apiportal.ns.nl/virtual-train-api"
    // API key must be set via environment variable NS_API_KEY
    // Get your free API key at: https://apiportal.ns.nl
    private let apiKey: String

    private init() {
        // Read API key from environment variable
        guard let key = ProcessInfo.processInfo.environment["NS_API_KEY"], !key.isEmpty else {
            fatalError("NS_API_KEY environment variable is not set. Get your free API key at https://apiportal.ns.nl")
        }
        self.apiKey = key
    }

    // MARK: - Fetch Stations

    func fetchStations() async throws -> [Station] {
        guard let url = URL(string: "\(baseURL)/stations") else {
            throw NSAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NSAPIError.httpError(statusCode: httpResponse.statusCode)
        }

        let stationsResponse = try JSONDecoder().decode(StationsResponse.self, from: data)
        return stationsResponse.payload.filter { $0.country == "NL" }
    }

    // MARK: - Fetch Departures

    func fetchDepartures(for stationCode: String, maxJourneys: Int = 20) async throws -> [Departure] {
        guard let url = URL(string: "\(baseURL)/departures?station=\(stationCode)&maxJourneys=\(maxJourneys)") else {
            throw NSAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NSAPIError.httpError(statusCode: httpResponse.statusCode)
        }

        let departuresResponse = try JSONDecoder().decode(DeparturesResponse.self, from: data)
        return departuresResponse.payload.departures
    }

    // MARK: - Fetch Arrivals

    func fetchArrivals(for stationCode: String, maxJourneys: Int = 20) async throws -> [Departure] {
        guard let url = URL(string: "\(baseURL)/arrivals?station=\(stationCode)&maxJourneys=\(maxJourneys)") else {
            throw NSAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            // Log response body for debugging
            if let errorBody = String(data: data, encoding: .utf8) {
                print("❌ Arrivals API Error (\(httpResponse.statusCode)): \(errorBody)")
            }
            throw NSAPIError.httpError(statusCode: httpResponse.statusCode)
        }

        // Debug: Print raw response to understand structure
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🚂 Arrivals API Response: \(jsonString.prefix(500))")
        }

        do {
            let arrivalsResponse = try JSONDecoder().decode(ArrivalsResponse.self, from: data)
            print("✅ Decoded \(arrivalsResponse.payload.arrivals.count) arrivals successfully")
            return arrivalsResponse.payload.arrivals
        } catch {
            print("❌ Arrivals Decoding error: \(error)")
            throw NSAPIError.decodingError(error)
        }
    }

    // MARK: - Fetch Trains (Virtual Train API)

    func fetchTrains(latitude: Double, longitude: Double, radius: Int = 50, limit: Int = 50) async throws -> [Train] {
        // Convert radius from km to meters for API
        let radiusInMeters = radius * 1000

        var components = URLComponents(string: "\(virtualTrainURL)/vehicle")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lng", value: String(longitude)),
            URLQueryItem(name: "radius", value: String(radiusInMeters)),
            URLQueryItem(name: "limit", value: String(limit))
        ]

        guard let url = components?.url else {
            throw NSAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Ocp-Apim-Subscription-Key")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            // Log response body for debugging
            if let errorBody = String(data: data, encoding: .utf8) {
                print("❌ Virtual Train API Error (\(httpResponse.statusCode)): \(errorBody)")
            }
            throw NSAPIError.httpError(statusCode: httpResponse.statusCode)
        }

        // Debug: Print raw response to understand structure
        if let jsonString = String(data: data, encoding: .utf8) {
            print("🚂 Virtual Train API Response: \(jsonString.prefix(500))")
        }

        do {
            let trainsResponse = try JSONDecoder().decode(TrainsResponse.self, from: data)
            print("✅ Decoded \(trainsResponse.payload.treinen.count) trains successfully")
            return trainsResponse.payload.treinen
        } catch {
            print("❌ Decoding error: \(error)")
            throw NSAPIError.decodingError(error)
        }
    }
}

// MARK: - API Errors

enum NSAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
