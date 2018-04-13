import UIKit

protocol VenuDetailPresenterType: ViewPresenterType {
    func attach(view: VenueDetailViewType)
    func generateImage(size: CGSize)
    func showDirections()
    func showInMaps()
}
