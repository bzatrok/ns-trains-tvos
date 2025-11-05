import Foundation

struct Departure: Decodable, Identifiable {
    let id: UUID
    let cancelled: Bool
    let company: String
    let delay: Int
    let departureTime: Date
    let destination: String
    let destinationCodes: [String]
    let platform: String
    let platformChanged: Bool
    let plannedPlatform: String
    let trainNumber: String
    let trainType: String
    let trainTypeCode: String
    let remarks: [String]
    let via: String

    enum CodingKeys: String, CodingKey {
        case cancelled
        case direction
        case plannedDateTime
        case actualDateTime
        case actualTrack
        case plannedTrack
        case routeStations
        case product
        case messages
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = UUID()
        self.cancelled = try container.decodeIfPresent(Bool.self, forKey: .cancelled) ?? false
        self.destination = try container.decode(String.self, forKey: .direction)

        // Parse date
        let plannedDateString = try container.decode(String.self, forKey: .plannedDateTime)
        let actualDateString = try? container.decode(String.self, forKey: .actualDateTime)

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]

        self.departureTime = dateFormatter.date(from: plannedDateString) ?? Date()

        // Calculate delay
        if let actualDateString = actualDateString,
           let plannedDate = dateFormatter.date(from: plannedDateString),
           let actualDate = dateFormatter.date(from: actualDateString) {
            self.delay = Int(actualDate.timeIntervalSince(plannedDate) / 60)
        } else {
            self.delay = 0
        }

        // Platform info
        self.platform = try container.decodeIfPresent(String.self, forKey: .actualTrack) ?? ""
        self.plannedPlatform = try container.decodeIfPresent(String.self, forKey: .plannedTrack) ?? ""
        self.platformChanged = self.platform != self.plannedPlatform && !self.platform.isEmpty

        // Product info
        if let productDict = try? container.decode([String: AnyCodable].self, forKey: .product) {
            self.company = productDict["operatorName"]?.value as? String ?? "NS"
            self.trainNumber = productDict["number"]?.value as? String ?? ""
            self.trainType = productDict["longCategoryName"]?.value as? String ?? "Intercity"
            self.trainTypeCode = productDict["categoryCode"]?.value as? String ?? "IC"
        } else {
            self.company = "NS"
            self.trainNumber = ""
            self.trainType = "Intercity"
            self.trainTypeCode = "IC"
        }

        // Route stations
        if let routeStations = try? container.decode([[String: AnyCodable]].self, forKey: .routeStations) {
            self.destinationCodes = routeStations.compactMap { $0["uicCode"]?.value as? String }
            let viaStations = routeStations.dropFirst().dropLast().compactMap { $0["mediumName"]?.value as? String }
            self.via = viaStations.joined(separator: ", ")
        } else {
            self.destinationCodes = []
            self.via = ""
        }

        // Messages
        if let messages = try? container.decode([[String: String]].self, forKey: .messages) {
            self.remarks = messages.compactMap { $0["message"] }
        } else {
            self.remarks = []
        }
    }
}

struct DeparturesResponse: Decodable {
    let payload: DeparturesPayload
}

struct DeparturesPayload: Decodable {
    let departures: [Departure]
}

// Helper to decode Any types from JSON
struct AnyCodable: Codable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
            self.value = string
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            self.value = dict.mapValues { $0.value }
        } else {
            self.value = NSNull()
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        default:
            try container.encodeNil()
        }
    }
}
