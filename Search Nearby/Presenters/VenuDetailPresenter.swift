import UIKit

class VenuDetailPresenter: VenuDetailPresenterType {

    let router: Router
    let venue: Venue
    let mapSnapshotter: MapSnapShotLoader

    weak var view: VenueDetailViewType!

    init(router: Router, venue: Venue) {
        self.router = router
        self.venue = venue
        self.mapSnapshotter = MapSnapShotLoader(latitude: Double(venue.address.latitude),
                                                longitude: Double(venue.address.longitude))
    }

    func generateImage(size: CGSize) {

        mapSnapshotter.generateSnapshot(of: size) { [weak self] image, error in
                                            guard let strongSelf = self else {
                                                return
                                            }

                                            if let error = error {
                                                print("Error occurred: \(error)")
                                                return
                                            }
                                            guard let image = image else {
                                                return
                                            }

                                            strongSelf.view.detailSnapshotGenerated(image: image)

        }
    }

    func attach(view: VenueDetailViewType) {
        self.view = view
    }

    func showInMaps() {
        router.showInMaps(venue: venue)
    }

    func showDirections() {
        router.showDirections(venue: venue)
    }
}
