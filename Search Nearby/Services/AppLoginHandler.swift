import UIKit

protocol OauthLoginServiceType: class {

    var accessTokenHandler: ((OauthCredential?, Error?) -> Void)? { get set }
    func handleOpen(url: URL) -> Bool
}

internal class OauthLoginService {
    
    internal var accessTokenHandler: ((OauthCredential?, Error?) -> Void)?

    fileprivate let target = RequestProvider<FourSquareOauthTarget>()

    internal func handleOpen(url: URL) -> Bool {
        guard let scheme = url.scheme else {
            return false
        }

        guard scheme == "searchnearby" else {
            return false
        }

        guard let query = url.query,
            let code = query.components(separatedBy: "code=").last else {
                return false
        }

        defer {
            handleAuthentication(code: code)
        }

        return true
    }

    internal func handleAuthentication(code: String) {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let clientCredentials = loadClientCredentials()!

        target.response(target: .accessToken(clientCredentials, code),
                        jsonDecoder: decoder) { [weak self] (credential: OauthCredential?, error: Error?) in
                            guard let strongSelf = self else {
                                return
                            }
                            strongSelf.accessTokenHandler?(credential, error)
        }
    }

    private func loadClientCredentials() -> ClientCredentials! {
        let appKeysFileName = "AppKeys.plist"

        let bundle = Bundle.main

        let resourceUrl = bundle.url(forResource: appKeysFileName,
                                     withExtension: nil)

        guard let appKeysUrl = resourceUrl else {
            assertionFailure("No client credentials found. This bundle should contain AppKeys.plist file with client_id and client_secret in it")
            return nil
        }

        guard let appKeys = NSDictionary(contentsOf: appKeysUrl) as? [String: String] else {
            assertionFailure("client credentials must be in the form of dictionary in plist file. <key>client_id</key><value>...</>. It must have client_id and client_secret")
            return nil
        }

        let clientIdKey = "client_id"
        let clientSecretKey = "client_secret"

        guard appKeys.keys.contains(clientIdKey),
            appKeys.keys.contains(clientSecretKey) else {
                assertionFailure("AppKeys.plist do not contain keys required for the application")
                return nil
        }

        let clientId = appKeys[clientIdKey]!
        let clientSecret = appKeys[clientSecretKey]!

        if clientId.count == 0 || clientSecret.count == 0 {
            assertionFailure("AppKeys.plist should have values for client_id and client_secret")
            return nil
        }

        return ClientCredentials(clientId: clientId,
                                 clientSecret: clientSecret)
    }
}

extension OauthLoginService: OauthLoginServiceType {}
