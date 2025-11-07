import Foundation
import MapKit

struct Station: Decodable, Identifiable, Hashable {
    let id: String
    let code: String
    let name: String
    let country: String
    let uicCode: String?
    let latitude: Double
    let longitude: Double

    // Computed property for MapKit
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    enum CodingKeys: String, CodingKey {
        case code
        case name = "namen"
        case country = "land"
        case uicCode = "UICCode"
        case latitude = "lat"
        case longitude = "lng"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decode(String.self, forKey: .code)
        self.id = self.code

        // Handle nested "namen" object with "lang" key
        if let namenDict = try? container.decode([String: String].self, forKey: .name) {
            self.name = namenDict["lang"] ?? ""
        } else {
            self.name = ""
        }

        self.country = try container.decode(String.self, forKey: .country)
        self.uicCode = try? container.decode(String.self, forKey: .uicCode)

        // Decode coordinates, defaulting to center of Netherlands if not available
        self.latitude = try container.decodeIfPresent(Double.self, forKey: .latitude) ?? 52.2
        self.longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) ?? 5.5
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }

    static func == (lhs: Station, rhs: Station) -> Bool {
        lhs.code == rhs.code
    }
}

struct StationsResponse: Decodable {
    let payload: [Station]
}
