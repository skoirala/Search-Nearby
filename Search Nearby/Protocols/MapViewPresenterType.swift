import Foundation

protocol MapViewPresenterType: ViewPresenterType {

    func attach(view: MapViewType)
    func viewAppeared()
    func showVenueDetail()
}
