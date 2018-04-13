import Foundation

struct Category {
    let identifier: String
    let name: String
    let iconPrefix: String
    let iconSuffix: String
}

extension Category {

    var thumbnailUrl: String {
        return iconPrefix + "88" + iconSuffix
    }
}

extension Category: Decodable {
    enum RootKeys: String, CodingKey {
        case identifier = "id", name, icon, prefix, suffix
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootKeys.self)
        try name = container.decode(String.self,
                                    forKey: .name)
        try identifier = container.decode(String.self,
                                          forKey: .identifier)
        let iconContainer = try container.nestedContainer(keyedBy: RootKeys.self,
                                                          forKey: .icon)
        try iconPrefix = iconContainer.decode(String.self,
                                              forKey: .prefix)
        try iconSuffix = iconContainer.decode(String.self,
                                              forKey: .suffix)
    }
}
