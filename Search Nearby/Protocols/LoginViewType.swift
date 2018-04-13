import Foundation

protocol LoginViewType: class {
    func handleLoginSuccess(with token: OauthCredential)
    func showProgress()
    func showError(error: String)
}
