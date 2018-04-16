import UIKit

protocol VenuePhotoPresenterType: ViewPresenterType {
    func venueTitle() -> String
    func attach(view: VenuePhotoViewType)
    func showMaps()
    func numberOfVenuePhotos() -> Int
    func sizeForVenuePhoto(at index: Int) -> CGSize
    func imageForVenuePhoto(at index: Int) -> UIImage?
    func showPhotoViewer(at index: Int)
}
