import Foundation

struct VenuePhotoResponse {
    let count: Int
    let photos: [VenuePhoto]
}

extension VenuePhotoResponse: Decodable {
    enum RootKeys: CodingKey {
        case response, photos, count, items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        let responseContainer = try container.nestedContainer(keyedBy: RootKeys.self,
                                                              forKey: .response)
        let photosContainer = try responseContainer.nestedContainer(keyedBy: RootKeys.self,
                                                                    forKey: .photos)
        count = try photosContainer.decode(Int.self,
                                           forKey: .count)
        photos = try photosContainer.decode([VenuePhoto].self,
                                            forKey: .items)
    }
}

struct VenuePhoto: Decodable {

    enum CodingKeys: String, CodingKey {
        case createdAt, height, width, identifier = "id", prefix, suffix
    }

    let createdAt: TimeInterval
    let height: Int
    let width: Int
    let identifier: String
    let prefix: String
    let suffix: String
}

extension VenuePhoto {
    var thumbnailUrl: String {
        return prefix + "\(300)x\(500)" + suffix
    }
}
