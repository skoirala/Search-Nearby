import UIKit

protocol PhotoViewerViewType: class {
    func loadProgress(progress: CGFloat)
    func didLoad(image: UIImage)
}
