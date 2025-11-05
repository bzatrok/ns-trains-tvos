import Foundation

struct Station: Decodable, Identifiable, Hashable {
    let id: String
    let code: String
    let name: String
    let country: String
    let uicCode: String?

    enum CodingKeys: String, CodingKey {
        case code
        case name = "namen"
        case country = "land"
        case uicCode = "UICCode"
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
