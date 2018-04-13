import Foundation

struct Venue {
    let identifier: String
    let name: String
    let address: Address
    let categories: [Category]

    var category: Category? {
        return categories.first
    }
}

extension Venue {

    func displayResult() -> VenueDisplayResult {

        let categoryName: String?

        if let category = category {
            categoryName = category.name
        } else {
            categoryName = nil
        }
        return VenueDisplayResult(name: name,
                                  address: address.formatted,
                                  categoryName: categoryName,
                                  imageUrl: category?.thumbnailUrl)
    }
}

extension Venue: Decodable {
    enum RootKeys: String, CodingKey {
        case name, identifier = "id", location, categories
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        try identifier = container.decode(String.self,
                                          forKey: .identifier)
        try name = container.decode(String.self,
                                    forKey: .name)
        try address = container.decode(Address.self,
                                       forKey: .location)
        try categories = container.decode([Category].self,
                                          forKey: .categories)
    }
}
