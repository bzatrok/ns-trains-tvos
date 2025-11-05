import Foundation

class NSAPIService {
    static let shared = NSAPIService()

    private let baseURL = "https://gateway.apiportal.ns.nl/reisinformatie-api/api/v2"
    private let apiKey = "e221602026d94edfb75afbf75d256455" // Public API key from NS portal

    private init() {}

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
