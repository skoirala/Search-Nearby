import UIKit

protocol VenuePhotoViewType: class {
    func venuePhotosLoadingStarted()
    func venuePhotosLoaded()
    func venuePhotoLoading(failed error: Error)
    func venuePhotoLoadingReturnedEmpty()

    func image(_ image: UIImage, downloadedAt index: Int)
}
