import UIKit

protocol SearchVenuePresenterType: ViewPresenterType {

    func attach(view: SearchVenueViewType)

    func numberOfItems() -> Int

    func item(at index: Int) -> VenueDisplayResult

    func search(for venue: String)

    func itemSelected(at index: Int)

    func image(at index: Int) -> UIImage?
}
