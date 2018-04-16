import Foundation

protocol LoginViewPresenterType: ViewPresenterType {
    func startAuthorization()
    func attach(view: LoginViewType)
}
