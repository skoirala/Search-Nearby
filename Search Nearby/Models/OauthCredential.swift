import Foundation

internal struct OauthCredential: Codable {
    internal let accessToken: String

    fileprivate enum CodingKeys: CodingKey {
        case accessToken
    }
}
