import UIKit

protocol SearchVenueViewType: class {
    func searchResultChanged()
    func imageDownloadFinished(image: UIImage, for url: String)
}
