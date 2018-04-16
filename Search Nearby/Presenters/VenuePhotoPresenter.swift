import UIKit

class VenuePhotoPresenter {
    
    let router: Router
    let storage: Storage
    let target: RequestProvider<FourSquareRequestTarget>
    let venue: Venue
    weak var view: VenuePhotoViewType!

    var venuePhotoResponse: VenuePhotoResponse?

    init(router: Router,
         storage: Storage,
         venue: Venue) {

        self.router = router
        self.storage = storage
        self.venue = venue
        target = RequestProvider<FourSquareRequestTarget>()
    }

    func loadPhotos() {
        let credentials = try! storage.credential()

        let params = (venueId: venue.identifier,
                      accessToken: credentials.accessToken)

        view.venuePhotosLoadingStarted()

        target.response(target: .venuePhotos(params)) { [weak self] (photoResponse: VenuePhotoResponse?, error) in
            guard let strongSelf = self else {
                return
            }

            if let error = error {
                strongSelf.view.venuePhotoLoading(failed: error)
                return
            }

            guard let venuePhotoResponse = photoResponse else {
                let unknownError = NSError(domain: "com.venuePhotoPresenter",
                                           code: 0,
                                           userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
                strongSelf.view.venuePhotoLoading(failed: unknownError)
                return
            }

            guard venuePhotoResponse.count > 0 else {
                strongSelf.venuePhotoResponse = nil
                strongSelf.view.venuePhotoLoadingReturnedEmpty()
                return
            }

            strongSelf.venuePhotoResponse = photoResponse
            strongSelf.view.venuePhotosLoaded()
        }
    }
}

extension VenuePhotoPresenter: VenuePhotoPresenterType {

    func attach(view: VenuePhotoViewType) {
        self.view = view
        loadPhotos()
    }

    func showPhotoViewer(at index: Int) {
        guard let venuePhoto = venuePhotoResponse?.photos[index] else {
            return
        }
        router.showPhotoViewer(photo: venuePhoto)
    }

    func showMaps() {
        router.showMapView(venue: venue)
    }

    func venueTitle() -> String {
        return venue.name
    }

    func numberOfVenuePhotos() -> Int {
        guard let venuePhotoResponse = venuePhotoResponse else {
            return 0
        }

        return venuePhotoResponse.photos.count
    }

    func imageForVenuePhoto(at index: Int) -> UIImage? {
        guard let venuePhoto = venuePhotoResponse?.photos[index] else {
            return nil
        }

        let imageDownloader = ImageDownloader.default

        if let image = imageDownloader.image(for: venuePhoto.thumbnailUrl) {
            return image
        }

        imageDownloader.getImage(for: venuePhoto.thumbnailUrl) { [weak self] image in
            guard let strongSelf = self else { return }
            strongSelf.view.image(image, downloadedAt: index)
        }

        return nil
    }

    func sizeForVenuePhoto(at index: Int) -> CGSize {
        guard let venuePhotoResponse = venuePhotoResponse else {
            return .zero
        }

        let venuePhoto = venuePhotoResponse.photos[index]
        return CGSize(width: venuePhoto.width,
                      height: venuePhoto.height)
    }

}
