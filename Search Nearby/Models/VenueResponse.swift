import Foundation

struct VenueResponse {
    let code: Int
    let venues: [Venue]
}

extension VenueResponse: Decodable {
    enum RootKeys: CodingKey {
        case meta, code, response, venues
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        let metaContainer = try container.nestedContainer(keyedBy: RootKeys.self,
                                                          forKey: .meta)
        try code = metaContainer.decode(Int.self,
                                        forKey: .code)
        let responseContainer = try container.nestedContainer(keyedBy: RootKeys.self,
                                                              forKey: .response)
        try venues = responseContainer.decode([Venue].self,
                                              forKey: .venues)
    }
}
