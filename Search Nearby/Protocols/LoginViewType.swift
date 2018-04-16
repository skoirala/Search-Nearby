import Foundation

protocol LoginViewType: class {
    func handleLoginSuccess()
    func showProgress()
    func showError(error: String)
}
