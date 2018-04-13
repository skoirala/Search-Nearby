import Foundation

protocol ViewPresenterType {
    associatedtype ViewType

    var view: ViewType! { get }
    func attach(view: ViewType)
}
