import Foundation

enum App {

    static let credentialStorageKey = "com.UserCredentialManager.storage.isLoggedInKey"
    static let ouathRedirectURL = "SearchNearby://authorize"
    static let oauthServerURL = "https://foursquare.com/oauth2/"

    static let latitudeStorageKey = "SearchNearby.LocationService.latitudeStorageKey"
    static let longitudeStorageKey = "SearchNearby.LocationService.longitudeStorageKey"
    static let locationUpdatedTimestampKey = "SearchNearby.LocationService.locationUpdatedTimestampKey"

    static let defaultLatitude = 60.1699
    static let defaultLongitude = 24.9384
}
