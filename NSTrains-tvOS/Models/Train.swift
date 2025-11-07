import Foundation
import MapKit

struct Train: Decodable, Identifiable {
    let id: String
    let ritId: String
    let trainNumber: Int
    let latitude: Double
    let longitude: Double
    let speed: Double
    let direction: Double
    let type: String
    let horizontalAccuracy: Double?

    // Computed property for MapKit
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // Format speed for display
    var formattedSpeed: String {
        "\(Int(speed)) km/h"
    }

    // Get train type code (type is already "IC", "SPR", etc.)
    var typeCode: String {
        type
    }

    enum CodingKeys: String, CodingKey {
        case ritId
        case treinNummer
        case lat
        case lng
        case snelheid
        case richting
        case type
        case horizontaleNauwkeurigheid
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.ritId = try container.decode(String.self, forKey: .ritId)
        self.trainNumber = try container.decode(Int.self, forKey: .treinNummer)
        self.id = "\(trainNumber)-\(ritId)" // Unique ID combining train number and rit

        self.latitude = try container.decode(Double.self, forKey: .lat)
        self.longitude = try container.decode(Double.self, forKey: .lng)
        self.speed = try container.decode(Double.self, forKey: .snelheid)
        self.direction = try container.decode(Double.self, forKey: .richting)
        self.type = try container.decode(String.self, forKey: .type)
        self.horizontalAccuracy = try? container.decode(Double.self, forKey: .horizontaleNauwkeurigheid)
    }
}

struct TrainsResponse: Decodable {
    let payload: TrainsPayload
}

struct TrainsPayload: Decodable {
    let treinen: [Train]
}
