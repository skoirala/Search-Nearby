import Foundation

internal class LoginViewPresenter {

    internal weak var view: LoginViewType!

    private let authenticationManager: OauthAuthenticationManagerType
    private let router: Router

    internal init(router: Router,
                  storage: Storage,
                  authenticationManager: OauthAuthenticationManagerType) {
        self.router = router
        self.authenticationManager = authenticationManager
        self.authenticationManager.observe = { [weak self] token, error in
            guard let strongSelf = self else {
                return
            }

            strongSelf.handle(token: token, error: error)
        }
    }

    private func handle(token: OauthCredential?, error: Error?) {

        if let error = error {
            view.showError(error: error.localizedDescription)
            return
        }

        if token == nil {
            view.showError(error: "Unknown error occurred")
            return
        }

        view.handleLoginSuccess(with: token!)
    }
}

extension LoginViewPresenter: LoginViewPresenterType {
    
    func startAuthorization() {
        view.showProgress()
        authenticationManager.startAuthorization()
    }

    func attach(view: LoginViewType) {
        self.view = view
    }

    func handleLoginSuccess() {
        router.showSearchViewController()
    }
}
