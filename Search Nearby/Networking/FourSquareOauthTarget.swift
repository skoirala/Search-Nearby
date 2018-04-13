import Foundation

struct ClientCredentials {
    let clientId: String
    let clientSecret: String
}

enum FourSquareOauthTarget: RequestTarget {

    case accessToken(ClientCredentials, String)

    var baseUrl: String {
        return App.oauthServerURL
    }

    var params: [String: String] {
        switch self {
        case .accessToken(let appKeys, let code):
            return [
                "code": code,
                "client_id": appKeys.clientId,
                "client_secret": appKeys.clientSecret,
                "redirect_uri": App.ouathRedirectURL,
                "grant_type": "authorization_code"
            ]
        }
    }

    var path: String {
        return "access_token"
    }

    var method: HttpMethod {
        return .get
    }
}
