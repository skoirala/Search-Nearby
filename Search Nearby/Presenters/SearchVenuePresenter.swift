import Foundation
import UIKit

class SearchVenuePresenter {

    weak var pendingTask: URLSessionTask? 

    let router: Router
    let storage: Storage
    let locationService: LocationService

    let imageDownloader = ImageDownloader.default
    let requestProvider = RequestProvider<FourSquareRequestTarget>()

    var displayResults: [VenueDisplayResult] = []
    var venues: [Venue] = []

    weak var view: SearchVenueViewType!

    init(router: Router,
         storage: Storage) {
        self.router = router
        self.storage = storage
        self.locationService = LocationService(storage: storage)
    }

    func notifyView() {
        view.searchResultChanged()
    }

    func handle(result: VenueResponse?, error: Error?) {
        guard let result = result else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.venues = result.venues
            strongSelf.displayResults = result.venues.map { $0.displayResult() }
            strongSelf.notifyView()
        }
    }
}

// - MARK: SearchVenuePresenterType

extension SearchVenuePresenter: SearchVenuePresenterType {

    func numberOfItems() -> Int {
        return displayResults.count
    }

    func itemSelected(at index: Int) {
        let venue = venues[index]
        router.showVenuePhotos(venue: venue)
    }

    func item(at index: Int) -> VenueDisplayResult {
        return displayResults[index]
    }

    func attach(view: SearchVenueViewType) {
        self.view = view
        view.searchResultChanged()
        locationService.updateLocation()
    }

    func search(for searchText: String) {
        guard !searchText.isEmpty else {
            venues = []
            displayResults = []

            notifyView()
            return
        }

        pendingTask?.cancel()

        let credentials: OauthCredential = try! storage.credential()
        let location = locationService.lastUpdatedLocation()

        let targetParams = (searchText: searchText,
                            accessToken: credentials.accessToken,
                            (latitude: location.latitude,
                             longitude: location.longitude))

        pendingTask = requestProvider.response(target: .searchVenues(targetParams)) { [weak self] (result: VenueResponse?, error: Error?) in

            guard let strongSelf = self else {
                return
            }
            strongSelf.handle(result: result,
                              error: error)
        }
    }

    func image(at index: Int) -> UIImage? {

        guard let imageUrl = displayResults[index].imageUrl else {
            return UIImage(named: "NoImage")
        }

        if let image = imageDownloader.image(for: imageUrl) {
            return image
        }

        downloadImage(for: imageUrl)
        return nil
    }

    func downloadImage(for imageUrl: String) {
        imageDownloader.getImage(for: imageUrl) { [weak self] image  in

            guard let strongSelf = self else {
                return
            }

            strongSelf.view.imageDownloadFinished(image: image,
                                                  for: imageUrl)
        }
    }
}
