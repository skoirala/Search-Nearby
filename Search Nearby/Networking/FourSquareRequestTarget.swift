import Foundation

struct SearchVenueParams {
    let searchText: String
    let accessToken: String
    let latitude: Double
    let longitude: Double
}

enum FourSquareRequestTarget: RequestTarget {

    case searchVenues(SearchVenueParams)

    var baseUrl: String {
        return "https://api.foursquare.com/v2/"
    }

    var params: [String: String] {
        switch self {
        case .searchVenues(let venueParams):

            let llValue = "\(venueParams.latitude),\(venueParams.longitude)"
            let additionalParams = ["oauth_token": venueParams.accessToken,
                                    "query": venueParams.searchText,
                                    "ll": llValue]

            return defaultVenueParams.merging(additionalParams) { $1 }
        }
    }

    var path: String {
        switch self {
        case .searchVenues:
            return "venues/search/"
        }
    }

    var method: HttpMethod {
        return .get
    }
    var defaultVenueParams: [String: String] {
        return ["ll": "60.289901,25.043335",
                "v": "20180411",
                "limit": "50"]

    }
}
