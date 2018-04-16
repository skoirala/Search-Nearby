import Foundation

typealias LocationParams = (latitude: Double, longitude: Double)
typealias SearchVenueParams = (searchText: String, accessToken: String, location: LocationParams)
typealias VenuePhotosParams = (venueId: String, accessToken: String)

enum FourSquareRequestTarget {
    case searchVenues(SearchVenueParams)
    case venuePhotos(VenuePhotosParams)
}

extension FourSquareRequestTarget: RequestTarget {

    var baseUrl: String {
        return "https://api.foursquare.com/v2/"
    }

    var params: [String: String] {
        let defaultParams =  ["v": "20180411",
                              "limit": "50"]

        switch self {
        case .searchVenues(let venueParams):

            let llValue = "\(venueParams.location.latitude),\(venueParams.location.longitude)"
            let additionalParams = ["oauth_token": venueParams.accessToken,
                                    "query": venueParams.searchText,
                                    "ll": llValue]
            return defaultParams.merging(additionalParams) { $1 }

        case .venuePhotos(let venuePhotoParams):
            let additionalParams = ["oauth_token": venuePhotoParams.accessToken]
            return defaultParams.merging(additionalParams) { $1 }
        }
    }

    var path: String {
        switch self {
        case .searchVenues:
            return "venues/search/"
        case .venuePhotos(let venuePhotoParams):
            return "venues/\(venuePhotoParams.venueId)/photos/"
        }
    }

    var method: HttpMethod {
        return .get
    }
}
