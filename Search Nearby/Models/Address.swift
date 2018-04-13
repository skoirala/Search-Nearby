import Foundation

struct Address: Decodable {
    let street: String?
    let city: String?
    let country: String
    let distance: Float
    let latitude: Double
    let longitude: Double
    let postalCode: String?
    let state: String?

    var formatted: String {
        var formattedAddress = ""
        if let street = street {
            formattedAddress += street + ", "
        }

        if let city = city {
            formattedAddress += city + " "
        }

        if let postalCode = postalCode {
            formattedAddress += postalCode
        }
        return formattedAddress
    }

    enum CodingKeys: String, CodingKey {
        case street = "address", city, country, distance, latitude = "lat", longitude = "lng", postalCode, state
    }
}
