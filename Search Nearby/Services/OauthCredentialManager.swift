import UIKit

protocol OauthAuthenticationManagerType: class {
    var observe: ((OauthCredential?, Error?) -> Void)? { get set }
    
    func startAuthorization()
}

class OauthAuthenticationManager {

    enum OauthAuthenticationError: Error {
        case invalidJsonDataStored
        case invalidToken
    }

    let storage: Storage
    let loginService: OauthLoginService

    var observe: ((OauthCredential?, Error?) -> Void)?

    init(storage: Storage,
         loginService: OauthLoginService) {

        self.storage = storage
        self.loginService = loginService

        loginService.accessTokenHandler = { [weak self] token, error in
            guard let strongSelf = self else {
                return
            }
            strongSelf.handle(token: token, error: error)
        }
    }

    private func handle(token: OauthCredential?, error: Error?) {
        if let error = error {
            notifyError(error: error)
            return
        }

        guard let token = token else {
            notifyError(error: OauthAuthenticationError.invalidToken)
            return
        }
        store(credential: token)
    }

    func store(credential: OauthCredential) {
        do {
            try storage.store(credential: credential)
            notifySuccess(oauthCredential: credential)
        } catch {
            notifyError(error: error)
        }
    }

    func notifySuccess(oauthCredential: OauthCredential) {
        observe?(oauthCredential, nil)
    }

    func notifyError(error: Error) {
        observe?(nil, error)
    }

    func isLoggedIn() -> Bool {
        let credential: Data? = storage.value(for: App.credentialStorageKey)
        return credential != nil
    }

    func handleAuthentication(url: URL) -> Bool {
        return self.loginService.handleOpen(url: url)
    }

    public func startAuthorization() {
        let authenticationUrl = createOauthAuthenticationURL(clientId: "NDBOVZ4HXIRKKRNTRJW3V4YHUALOA1UB02ZR2Q32O5NOCYRN")
        UIApplication.shared.open(authenticationUrl,
                                  options: [:],
                                  completionHandler: nil)
    }

    func createOauthAuthenticationURL(clientId: String) -> URL {
        let oauthURLString = App.oauthServerURL
                                        + "authenticate"
                                        + "?"
                                        + "client_id="
                                        + clientId
                                        + "&response_type="
                                        + "code"
                                        + "&redirect_uri="
                                        + App.ouathRedirectURL
        return URL(string: oauthURLString)!

    }
}

extension OauthAuthenticationManager: OauthAuthenticationManagerType {}
